# Monitoring module: Action Groups and Alert Rules

# Action Group for email notifications
resource "azurerm_monitor_action_group" "email_action_group" {
  name                = "email-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "email-ag"
  tags                = var.tags

  email_receiver {
    name                    = "admin-email"
    email_address          = var.alerts_email
    use_common_alert_schema = true
  }
}

# Alert Rule for HTTP 5xx errors from Application Gateway
resource "azurerm_monitor_scheduled_query_rules_alert" "http_5xx_alert" {
  name                = "http-5xx-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  data_source_id = var.log_analytics_workspace_id
  query           = <<-QUERY
    AzureDiagnostics
    | where ResourceType == "APPLICATIONGATEWAYS"
    | where Category == "ApplicationGatewayAccessLog"
    | where httpStatus_d >= 500
    | summarize count() by bin(TimeGenerated, 5m)
    | where count_ > 0
    | extend error_rate = count_ * 100.0 / toscalar(
        AzureDiagnostics
        | where ResourceType == "APPLICATIONGATEWAYS"
        | where Category == "ApplicationGatewayAccessLog"
        | summarize count() by bin(TimeGenerated, 5m)
        | summarize sum(count_)
      )
    | where error_rate > 1.0
  QUERY

  time_window = 5
  frequency   = 5

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.email_action_group.id]
  }

  description = "Alert when HTTP 5xx error rate exceeds 1% for 5 minutes"
}

# Metric Alert for Application Gateway backend health
resource "azurerm_monitor_metric_alert" "appgw_backend_health" {
  name                = "appgw-backend-health-alert"
  resource_group_name = var.resource_group_name
  scopes               = [var.application_gateway_id]
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnHealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  window_size        = "PT5M"
  frequency          = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.email_action_group.id
  }

  description = "Alert when Application Gateway has unhealthy backend hosts"
}

# Metric Alert for Container App CPU usage
resource "azurerm_monitor_metric_alert" "container_app_cpu" {
  name                = "container-app-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes               = [var.container_app_id]
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size        = "PT5M"
  frequency          = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.email_action_group.id
  }

  description = "Alert when Container App CPU usage exceeds 80%"
}

# Metric Alert for Container App memory usage
resource "azurerm_monitor_metric_alert" "container_app_memory" {
  name                = "container-app-memory-alert"
  resource_group_name = var.resource_group_name
  scopes               = [var.container_app_id]
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size        = "PT5M"
  frequency          = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.email_action_group.id
  }

  description = "Alert when Container App memory usage exceeds 80%"
} 