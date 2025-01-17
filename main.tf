terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.2"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.5"
    }
  }
  required_version = ">= 1.10.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

  storage_use_azuread = true
}

data "azuread_client_config" "this" {}

locals {
  app_name = "cmkdemo"
  rg_name  = "rg-${local.app_name}-${random_string.suffix.result}"
  uai_name = "uai-${local.app_name}-${random_string.suffix.result}"
  kv_name  = "kv-${local.app_name}-${random_string.suffix.result}"
  key_name = "cmk-${local.app_name}-${formatdate("YYYYMMDD-hhmm", time_static.current.rfc3339)}"
  st_name  = "st${local.app_name}${random_string.suffix.result}"
}

resource "time_static" "current" {}

data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "this" {
  name                = local.uai_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_key_vault" "this" {
  name                = local.kv_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku_name                   = "standard"
  tenant_id                  = data.azuread_client_config.this.tenant_id
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }

}

resource "azurerm_role_assignment" "uai" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_key_vault_key" "this" {
  key_opts     = ["wrapKey", "unwrapKey"]
  key_type     = "RSA"
  key_size     = 2048
  key_vault_id = azurerm_key_vault.this.id
  name         = local.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_storage_account" "this" {
  name                = local.st_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.this.id
    user_assigned_identity_id = azurerm_user_assigned_identity.this.id
  }

  network_rules {
    ip_rules       = ["${chomp(data.http.icanhazip.response_body)}"]
    bypass         = ["Logging", "Metrics", "AzureServices"]
    default_action = "Deny"
  }

  depends_on = [azurerm_key_vault.this.id, azurerm_role_assignment.uai.id]

}