variable "vnet_name" {
  description = "Name of the virtual network."
}
variable "address_space" {
  description = "Address space for the virtual network."
  type = string
}
variable "location" {
  description = "Azure region for the network resources."
}
variable "resource_group_name" {
  description = "Resource group name for the network resources."
}
variable "subnet_app_prefix" {
  description = "Address prefixes for the app subnet."
  type = string
}
variable "subnet_db_prefix" {
  description = "Address prefixes for the database subnet."
  type = string
}
variable "subnet_appgw_prefix" {
  description = "Address prefixes for the Application Gateway subnet."
  type = string
}
variable "tags" {
  description = "Tags to apply to network resources."
  type        = map(string)
  default     = {}
}
