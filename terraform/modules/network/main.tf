// Network module: VNet, subnets, NSGs
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

}
resource "azurerm_subnet" "appgw" {
  name                 = "appgw_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_appgw_prefix]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "app" {
  name                 = "app_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_app_prefix]
  
  delegation {
    name = "containerappdelegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
  
}

resource "azurerm_subnet" "db" {
  name                 = "db_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_db_prefix]
}


resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg_app"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  security_rule {
    access                       = "Allow"
    description                  = "AllowAppGwToAppHttps"
    destination_address_prefixes = [var.subnet_app_prefix]
    destination_port_ranges      = ["443"]
    direction                    = "Inbound"
    name                         = "AllowAppGwToAppHttps"
    priority                     = 100
    protocol                     = "Tcp"
    source_address_prefixes      = [var.subnet_appgw_prefix]
    source_port_range =  "*" 
  }

  
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "app_association" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}



resource "azurerm_network_security_group" "db" {
  name                = "nsg_db"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "AllowAppToDB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix    = var.subnet_app_prefix
    source_port_range        =  "*"     
    destination_port_range     = 5432
    destination_address_prefix = var.subnet_db_prefix
  }
  security_rule {
    name                       = "DefaultDenyInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}


output "app_subnet_id" {
  value = azurerm_subnet.app.id
   description = "Subnet for Container Apps"
}

output "database_subnet_id" {
  value = azurerm_subnet.db.id
   description = "Subnet for Database"
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
   description = "Subnet for Application Gateway"
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
   description = "Virtual Network ID"
}