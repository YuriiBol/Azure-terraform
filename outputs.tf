output "webapp_url" {
  value = azurerm_linux_web_app.app.default_hostname 
}

output "webapp_ips" {
  value = azurerm_linux_web_app.app.outbound_ip_addresses
}

output "StgActName" {
  value = module.StorageAccount.stg_act_name_out
}