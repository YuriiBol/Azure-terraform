

resource "azurerm_storage_account" "storage" {
  name                     = "${lower(var.base_name)}${var.random_ending}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}