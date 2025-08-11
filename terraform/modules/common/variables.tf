variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "law_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default = "law-secure-test"
}

variable "law_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "law_retention" {
  description = "Retention in days for Log Analytics Workspace"
  type        = number
  default     = 30
}

variable "kv_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-secure-test"
}

variable "kv_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
