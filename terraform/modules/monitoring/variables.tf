variable "resource_group_name" {
  description = "Resource group name for the monitoring resources."
  type        = string
}

variable "location" {
  description = "Azure region for the monitoring resources."
  type        = string
}

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}

variable "alerts_email" {
  description = "Email address for alert notifications."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace for query-based alerts."
  type        = string
}

variable "application_gateway_id" {
  description = "ID of the Application Gateway for metric alerts."
  type        = string
}

variable "container_app_id" {
  description = "ID of the Container App for metric alerts."
  type        = string
} 