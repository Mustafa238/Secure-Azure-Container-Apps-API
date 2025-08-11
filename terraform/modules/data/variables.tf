variable "db_name" {
  description = "Name of the PostgreSQL database to create."
}
variable "location" {
  description = "Azure region for the PostgreSQL server."
}
variable "resource_group_name" {
  description = "Resource group name for the PostgreSQL server."
}
variable "admin_login" {
  description = "Admin username for the PostgreSQL server."
}
variable "storage_mb" {
  description = "Storage size in MB for the PostgreSQL server."
}
variable "subnet_id" {
  description = "Subnet ID for the PostgreSQL server deployment."
}
variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace to send diagnostics to."
  type        = string
}
variable "key_vault_id" {
  description = "ID of the Azure Key Vault to assign roles to."
  type        = string
}
variable "resource_tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
}