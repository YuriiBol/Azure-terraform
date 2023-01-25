 terraform {
backend "azurerm" {
    resource_group_name  = "tfstateRG02"
    storage_account_name = "tfstate021358608744"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
}
 }