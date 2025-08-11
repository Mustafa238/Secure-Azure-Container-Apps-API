// Common module: Azure Key Vault and Log Analytics Workspace

data "azurerm_client_config" "current" {}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
  tags = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                        = var.kv_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.kv_sku
  enable_rbac_authorization   = true
  purge_protection_enabled    = true # tfsec issue - uncomment if you want to enable purge protection
  soft_delete_retention_days = 7 # tfsec issue - uncomment if you want to set soft delete retention
  enabled_for_disk_encryption = true
  tags = var.tags
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [  "${trimspace(data.http.my_public_ip.response_body)}/32" ] 
  }
}


resource "azurerm_role_assignment" "user_key_vault_administrator" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_key_vault_certificates_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}


output "key_vault_id" {
  value = azurerm_key_vault.kv.id
  description = "ID of the Key Vault"
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
  description = "Name of the Log Analytics Workspace"
}