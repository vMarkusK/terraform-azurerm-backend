variable "appname" {
  description = "Unique identification"
  type        = string
  default     = "tfstate"

}
variable "subscription_id" {
  description = "Subscription ID for all resources"
  type        = string
}

variable "location" {
  description = "Location for all resources"
  type        = string
  default     = "germywestcentral"
}