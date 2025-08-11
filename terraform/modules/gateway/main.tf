# Gateway module: Azure Application Gateway with WAF

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw_ip" {
  name                = "${var.app_name}-appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  zones               = var.zones
}

# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-${var.app_name}"
  resource_group_name = var.resource_group_name
  firewall_policy_id = azurerm_web_application_firewall_policy.waf.id
  location            = var.location
  enable_http2        = true
  tags                = var.tags
  zones               = var.zones
  
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.appgw_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = "port_443"
    port = 443
  }
  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
    private_ip_address_allocation   = "Dynamic"
    private_link_configuration_name = "my-agw-private-link"
  }
  private_link_configuration {
    name = "my-agw-private-link"
    ip_configuration {
      name                          = "privateLinkIpConfig1"
      primary                       = true
      private_ip_address            = ""
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.appgw_subnet_id
    }
  }
  backend_address_pool {
    name = "quote-api-backend"
    ip_addresses = []
    fqdns = [var.container_app_fqdn]
  }

  backend_http_settings {
    name                  = "be-st-quote-api"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    probe_name            = "hp-quote-api-https"
    pick_host_name_from_backend_address = true
    trusted_root_certificate_names = []
  }

  http_listener {
    name                           = "fl-quote-api-https"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "secure-api-test.com.au"
    host_names                     = []
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "certificate-quote"
  }
  http_listener {
    name                           = "fl-quote-api-http"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
    require_sni                    = false
  }

  request_routing_rule {
    name                        = "rr-quote-api-https"
    backend_address_pool_name   = "quote-api-backend"
    backend_http_settings_name  = "be-st-quote-api"
    http_listener_name          = "fl-quote-api-https"
    priority                    = 1
    rule_type                   = "Basic"
    url_path_map_name           = ""
    rewrite_rule_set_name       = "rewrite-rule"
  }

  rewrite_rule_set {
    name = "rewrite-rule"
    rewrite_rule {
      name          = "NewRewrite"
      rule_sequence = 100
      request_header_configuration {
        header_name  = "X-Forwarded-Host"
        header_value = "\\{host\\}"
      }
    }
  }

  probe {
    name                = "hp-quote-api-https"
    protocol            = "Https"
    port                = 443
    path                = "/"
    interval            = var.health_probe_interval
    timeout             = var.health_probe_timeout
    unhealthy_threshold = var.health_probe_unhealthy_threshold
    pick_host_name_from_backend_http_settings = true
  }

  ssl_certificate {
    name     = "certificate-quote"
    data     = filebase64("${path.module}/certificates/server.pfx")
    password = file("${path.module}/certificates/password.txt")
  }

}

resource "azurerm_monitor_diagnostic_setting" "appgw_diag" {
  name                       = "appgw-diag"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }
  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}


resource "azurerm_web_application_firewall_policy" "waf" {
  name                = "waf-secure-api"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                =  var.tags
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  policy_settings {
    enabled                                   = true
    file_upload_enforcement                   = true
    file_upload_limit_in_mb                   = 100
    js_challenge_cookie_expiration_in_minutes = 5
    max_request_body_size_in_kb               = 128
    mode                                      = "Prevention"
    request_body_check                        = true
    request_body_enforcement                  = true
    request_body_inspect_limit_in_kb          = 128
  }
}

output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_ip.ip_address
}

