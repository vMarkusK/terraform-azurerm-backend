output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "container_name" {
  value = "tfstate"
}

output "key" {
  value = "${local.app_name}.terraform.tfstate"
}

output "use_azuread_auth" {
  value = "true"
}
