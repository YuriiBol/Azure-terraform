module "random" {
  source = "./RandomString"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = var.env
  }
}

resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "app" {
  name                = "${"mywebapp-"}${module.random.random_string}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:azurerm_mssql_server.sql.fully_qualified_domain_name Database=azurerm_mssql_database.db.name;User ID=azurerm_mssql_server.sql.administrator_login;Password=azurerm_mssql_server.sql.administrator_login_password;Trusted_Connection=False;Encrypt=True;"
  }
   depends_on = [
     azurerm_service_plan.plan
   ]
}

resource "azurerm_mssql_server" "sql" {
  name                         = "${lower(var.sql_server_name)}${module.random.random_string}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_firewall_rule" "mssql_db_rule1" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  depends_on = [
     azurerm_mssql_server.sql
   ]

}
resource "azurerm_mssql_database" "db" {
  name           = "ProductsDB"
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "Basic"
  zone_redundant = false
}

module "StorageAccount" {
  source                   = "./StorageAccount"
  base_name                = "TerraformExample01"
  random_ending            = module.random.random_string
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

}

resource "azurerm_mssql_database_extended_auditing_policy" "policy" {
  database_id                             = azurerm_mssql_database.db.id
  storage_endpoint                        = module.StorageAccount.primary_blob_endpoint
  storage_account_access_key              = module.StorageAccount.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 5
}

module "application_gateway" {
  source = "./AppGateway"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  backend_address_pool_name = "${"mywebapp-"}${module.random.random_string}"
  frontend_port_name = "myFrontendPort"
  frontend_ip_configuration_name = "myAGIPConfig"
  http_setting_name = "myHTTPsetting2"
  listener_name = "myListener"
  request_routing_rule_name = "myRoutingRule"
  redirect_configuration_name = "myRedirectConfig"
  default_app_hostname = azurerm_linux_web_app.app.default_hostname
  webapp = azurerm_linux_web_app.app.id
}