variable "app_name" {
  description = "Name of the App Service or Container App."
}
variable "location" {
  description = "Azure region for the compute resources."
}
variable "resource_group_name" {
  description = "Resource group name for the compute resources."
}
variable "network_id" {
  description = "Name of the Container App Environment."
}
# variable "db_connection_string" {}
variable "app_subnet_id" {
  description = "Subnet ID for the Container App environment."
}
variable "appgw_subnet_id" {
  description = "Application gateway subnet ID for the Container App environment private link."
}
variable "log_analytics_id" {
  description = "ID of the Log Analytics Workspace for diagnostics."
}
variable "tags" {
  description = "Tags to apply to compute resources."
  type        = map(string)
  default     = {}
}
variable "key_vault_id" {
  description = "ID of the Azure Key Vault to assign roles to."
  type        = string
}
variable "appgw_subnet_prefix" {
  description = "Address prefix for the Application Gateway subnet."
  type        = string
}
