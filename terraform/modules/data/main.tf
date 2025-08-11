resource "random_password" "pg_admin_password" {
  length  = 16          # The password will be 16 characters long
  special = false       # Do not include special characters to avoid connection string issues
  min_lower = 2
  min_upper = 2
  min_numeric = 2
  keepers = {
    resource_group_name = var.resource_group_name
  }
}

// Data module: PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "pg_quote_server" {
  name                = "pg-secure-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "GP_Standard_D2s_v3" # Example SKU
  administrator_login = var.admin_login
  administrator_password = random_password.pg_admin_password.result # Use a secure method for passwords in production
  storage_mb          = var.storage_mb
  version             = "15" # Specify the PostgreSQL version
  backup_retention_days = 7
  
  high_availability {
    mode = "ZoneRedundant"
    standby_availability_zone = "1" # Specify the standby zone
  }
  zone = 2
  tags = var.resource_tags
}

resource "azurerm_monitor_diagnostic_setting" "pg_flex_diag" {
  name                       = "pg-flex-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.pg_quote_server.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }
  enabled_log {
    category = "PostgreSQLFlexSessions"
  }
  enabled_log {
    category = "PostgreSQLFlexQueryStoreWaitStats"
  }
  enabled_log {
    category = "PostgreSQLFlexQueryStoreRuntime"
  }
  enabled_log {
    category = "PostgreSQLFlexTableStats"
  }
  enabled_log {
    category = "PostgreSQLFlexDatabaseXacts"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_postgresql_flexible_server_database" "pg_quote_database" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.pg_quote_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# resource "azurerm_key_vault_secret" "pg_password_secret" {
#   name         = "postgresql-admin-password"
#   value        = random_password.pg_admin_password.result 
#   key_vault_id = var.key_vault_id
#   content_type = "text/plain"
# }

# resource "azurerm_key_vault_secret" "pg_Connection_string_secret" {
#   name         = "postgresql-Connection-String"
#   value         = "host=${azurerm_postgresql_flexible_server.pg_quote_server.fqdn} port=5432 dbname=${azurerm_postgresql_flexible_server_database.pg_quote_database.name} user=${azurerm_postgresql_flexible_server.pg_quote_server.administrator_login}@${azurerm_postgresql_flexible_server.pg_quote_server.name} password=${random_password.pg_admin_password.result} sslmode=require"
#   key_vault_id = var.key_vault_id
#   content_type = "text/plain"
# }


output "postgresql_server_id" {
  value       = azurerm_postgresql_flexible_server.pg_quote_server.id
  description = "ID of the PostgreSQL Flexible Server"
}

output "postgresql_db_id" {
  value       = azurerm_postgresql_flexible_server_database.pg_quote_database.id
  description = "ID of the PostgreSQL database"
}