
resource "azurerm_virtual_network" "vnet1" {
  name                = "myVNet"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "myAGSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "myBackendSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip1" {
  name                = "myAGPublicIPAddress"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
}



resource "azurerm_application_gateway" "network" {
  name                = "myAppGateway"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

  backend_address_pool {
    name                  = var.backend_address_pool_name
    fqdns                 = [ var.default_app_hostname , ]
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    pick_host_name_from_backend_address = true
    probe_name            = "demo-apim-probe"
  }

  probe {
    interval                                  = 30
    name                                      = "demo-apim-probe"
    path                                      = "/"
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      body = ""
      status_code = [
        "200"
      ]
    }
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 10
  }


    depends_on = [
     var.webapp
   ]
}