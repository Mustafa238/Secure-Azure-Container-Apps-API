// main.tf wires together network, compute, and data modules

variable "resource_tags" {
  type = map(string)
  default = {
    environment = "test"
    project     = "lang-flow"
  }
}

resource "azurerm_resource_group" "rg_common" {
  name     = "rg-common"
  location = var.location
  tags     = var.resource_tags
}

module "common" {
  source              = "./modules/common"
  resource_group_name = azurerm_resource_group.rg_common.name
  location            = azurerm_resource_group.rg_common.location
  tags = var.resource_tags
}

resource "azurerm_resource_group" "rg_network" {
  name     = "rg-network"
  location = var.location
  tags     = var.resource_tags
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg_network.name
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.rg_network.location
  subnet_app_prefix = var.subnet_app_prefix
  subnet_db_prefix  = var.subnet_db_prefix
  subnet_appgw_prefix = var.subnet_appgw_prefix
  tags                = var.resource_tags
}

resource "azurerm_resource_group" "rg_data" {
  name     = "rg-data"
  location = var.location
  tags     = var.resource_tags
}

module "data" {
  source                     = "./modules/data"
  db_name                    = var.db_name
  location                   = azurerm_resource_group.rg_data.location
  resource_group_name        = azurerm_resource_group.rg_data.name
  admin_login                = var.admin_login
  storage_mb                 = var.storage_mb
  subnet_id                  = module.network.database_subnet_id
  log_analytics_workspace_id = module.common.log_analytics_workspace_id
  key_vault_id               = module.common.key_vault_id
  resource_tags              = var.resource_tags
}


resource "azurerm_resource_group" "rg_secure_api" {
  name     = "rg-secure-api"
  location = var.location
  tags     = var.resource_tags
}

module "compute" {
  source              = "./modules/compute"
  app_name            = var.app_name
  location            = azurerm_resource_group.rg_secure_api.location
  resource_group_name = azurerm_resource_group.rg_secure_api.name
  network_id          = module.network.vnet_id
  app_subnet_id        = module.network.app_subnet_id
  appgw_subnet_id      = module.network.appgw_subnet_id
  log_analytics_id     = module.common.log_analytics_workspace_id
  tags                 = var.resource_tags
  key_vault_id         = module.common.key_vault_id
  appgw_subnet_prefix  = var.subnet_appgw_prefix
}

resource "azurerm_resource_group" "rg_secure_appgw" {
  name     = "rg-appgw"
  location = var.location
  tags     = var.resource_tags
}

module "gateway" {
  source              = "./modules/gateway"
  app_name            = var.app_name
  location            = azurerm_resource_group.rg_secure_appgw.location
  resource_group_name = azurerm_resource_group.rg_secure_appgw.name
  appgw_subnet_id     = module.network.appgw_subnet_id
  container_app_fqdn  = module.compute.container_app_internal_fqdn
  tags                = var.resource_tags
  log_analytics_workspace_id = module.common.log_analytics_workspace_id
}

# Monitoring module for alerts and action groups
resource "azurerm_resource_group" "rg_monitoring" {
  name     = "rg-monitoring"
  location = var.location
  tags     = var.resource_tags
}

module "monitoring" {
  source                     = "./modules/monitoring"
  resource_group_name        = azurerm_resource_group.rg_monitoring.name
  location                   = azurerm_resource_group.rg_monitoring.location
  tags                       = var.resource_tags
  alerts_email                = var.alerts_email
  log_analytics_workspace_id = module.common.log_analytics_workspace_id
  application_gateway_id     = module.gateway.application_gateway_id
  container_app_id           = module.compute.container_app_id
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = module.gateway.public_ip_address
  
}

# curl --cacert terraform/modules/gateway/certificates/root.cer \
# --resolve 'secure-api-test.com.au:<public_ip_address>' \
# -H "Host: secure-api-test.com.au" \
# https://secure-api-test.com.au/api/quotes


# curl --cacert terraform/modules/gateway/certificates/root.cer --resolve 'secure-api-test.com.au:443:<public_ip_address>' -H "Host: secure-api-test.com.au" https://secure-api-test.com.au/api/quotes

