// Compute module: App Service or Container Apps
resource "azurerm_container_app_environment" "aca_secure_api_env" {
  name                       = "${var.app_name}-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_id
  infrastructure_subnet_id   = var.app_subnet_id
  infrastructure_resource_group_name = "ME_${var.app_name}-env_${var.resource_group_name}_australiaeast" 
  zone_redundancy_enabled = true
  internal_load_balancer_enabled = true
  logs_destination = "log-analytics"
  workload_profile {
    name = "Consumption"
    workload_profile_type = "Consumption"
    minimum_count = 0
    maximum_count = 0
  }
  tags = var.tags
}


resource "azurerm_container_app" "aca_secure_api" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.aca_secure_api_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single" # Or "Multiple" for blue/green deployments

  template {
    container {
      name   = "quotes-container"
      image  = "docker.io/pbgnz/random-quote-api:1.5.2"
      cpu    = 0.5
      memory = "1Gi"
    }
    min_replicas        = 0
    max_replicas        = 3
  }
  identity {
    type = "SystemAssigned"
  }
  workload_profile_name = "Consumption"
  ingress {
    external_enabled = true # Disable external access - only allow internal access
    target_port      = 8000   # The port your container listens on
    transport        = "auto"
    allow_insecure_connections = false
    ip_security_restriction {
      action           = "Allow"
      description      = "AllowTrafficFromAppgw"
      ip_address_range = var.appgw_subnet_prefix
      name             = "AllowTrafficFromAppgw"
    }
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
 
  max_inactive_revisions = 10 

  tags = var.tags
}

resource "azurerm_role_assignment" "aca_secure_api_secrets_officer" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_container_app.aca_secure_api.identity[0].principal_id
}

resource "azurerm_role_assignment" "aca_secure_api_certificates_officer" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_container_app.aca_secure_api.identity[0].principal_id
}

# Private DNS Zone for Container App Environment
resource "azurerm_private_dns_zone" "aca_environment_private_dns_zone" {
  name                = azurerm_container_app_environment.aca_secure_api_env.default_domain
  resource_group_name = var.resource_group_name
  tags                = var.tags
  soa_record {
    email        = "azureprivatedns-host.microsoft.com"
    expire_time  = 2419200
    minimum_ttl  = 10
    refresh_time = 3600
    retry_time   = 300
    tags         = {}
    ttl          = 3600
  }
}


resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "my-vnet-pdns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aca_environment_private_dns_zone.name
  virtual_network_id    = var.network_id
  registration_enabled  = true # Set to true to enable auto-registration
}

resource "azurerm_private_dns_a_record" "asterisk_record" {
  name                = "*" # This will create mywebapp.internal.contoso.com
  zone_name           = azurerm_private_dns_zone.aca_environment_private_dns_zone.name
  resource_group_name = azurerm_private_dns_zone.aca_environment_private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [ azurerm_container_app_environment.aca_secure_api_env.static_ip_address]
}

resource "azurerm_private_dns_a_record" "at_the_rate_record" {
  name                = "@" # This will create mywebapp.internal.contoso.com
  zone_name           = azurerm_private_dns_zone.aca_environment_private_dns_zone.name
  resource_group_name = azurerm_private_dns_zone.aca_environment_private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [ azurerm_container_app_environment.aca_secure_api_env.static_ip_address]
}

resource "azurerm_monitor_diagnostic_setting" "aca_diag_env" {
  name                       = "aca-diag"
  target_resource_id         = azurerm_container_app_environment.aca_secure_api_env.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "ContainerAppConsoleLogs"
  }
  enabled_log {
    category = "ContainerAppSystemLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "aca_diag" {
  name                       = "aca-diag"
  target_resource_id         = azurerm_container_app.aca_secure_api.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_metric {
    category = "AllMetrics"
  }
}
  


output "container_app_fqdn" {
  description = "External FQDN of the Container App"
  value       = azurerm_container_app.aca_secure_api.latest_revision_fqdn
}

output "container_app_internal_fqdn" {
  description = "Internal FQDN of the Container App"
  value       = azurerm_container_app.aca_secure_api.latest_revision_fqdn
}

output "container_app_id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.aca_secure_api.id
}