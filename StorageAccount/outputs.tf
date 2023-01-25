output "stg_act_name_out" {
  value = resource.azurerm_storage_account.storage.name
}

output "primary_blob_endpoint" {
 value = azurerm_storage_account.storage.primary_blob_endpoint
}

output "primary_access_key" {
 value =  azurerm_storage_account.storage.primary_access_key
}