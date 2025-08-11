variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "your-resource-group-name"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet_test"
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.20.0.0/16"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Australia East"
}

variable "subnet_appgw_prefix" {
  description = "Address prefixes for application gateway subnet"
  type        = string
  default     = "10.20.0.0/24"
}

variable "subnet_app_prefix" {
  description = "Address prefixes for app subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "subnet_db_prefix" {
  description = "Address prefixes for db subnet"
  type        = string
  default     = "10.20.2.0/24"
}

variable "app_name" {
  description = "Name of the App Service or Container App"
  type        = string
  default     = "aca-secure-api"
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "pg-secure-api-db"
}

variable "admin_login" {
  description = "Admin login for PostgreSQL"
  type        = string
  default     = "pgadmin"
}

variable "storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768 # [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]
}

variable "alerts_email" {
  description = "Email address for monitoring alert notifications."
  type        = string
  default     = "alers_email@example.com"
}



