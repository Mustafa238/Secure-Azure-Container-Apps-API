variable "app_name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the Application Gateway."
  type        = string
}

variable "location" {
  description = "Azure region for the Application Gateway."
  type        = string
}

variable "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet."
  type        = string
}

variable "container_app_fqdn" {
  description = "FQDN of the backend Container App."
  type        = string
}

variable "tags" {
  description = "Tags to apply to Application Gateway resources."
  type        = map(string)
  default     = {}
}

variable "custom_error_configurations" {
  description = "Custom error configurations for the Application Gateway."
  type = list(object({
    status_code           = string
    custom_error_page_url = string
  }))
  default = []
}

variable "waf_enabled" {
  description = "Enable WAF on Application Gateway."
  type        = bool
  default     = true
}

variable "waf_firewall_mode" {
  description = "WAF firewall mode (Detection or Prevention)."
  type        = string
  default     = "Prevention"
}

variable "waf_rule_set_version" {
  description = "WAF rule set version."
  type        = string
  default     = "3.2"
}

variable "appgw_capacity" {
  description = "Application Gateway capacity."
  type        = number
  default     = 2
}

# variable "health_probe_path" {
#   description = "Health probe path for backend health checks."
#   type        = string
#   default     = "/"
# }

variable "health_probe_interval" {
  description = "Health probe interval in seconds."
  type        = number
  default     = 30
}

variable "health_probe_timeout" {
  description = "Health probe timeout in seconds."
  type        = number
  default     = 30
}

variable "health_probe_unhealthy_threshold" {
  description = "Health probe unhealthy threshold."
  type        = number
  default     = 3
}

variable "health_probe_healthy_threshold" {
  description = "Health probe healthy threshold."
  type        = number
  default     = 2
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace to send Application Gateway diagnostics to."
  type        = string
} 
variable "zones" {
  description = "Availability zones for the Application Gateway."
  default = ["1", "2"]
  type        = list(string)
}
