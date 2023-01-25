variable "resource_group_name" {
      type = string
}

variable "resource_group_location" {
  type = string
}

variable "backend_address_pool_name" {
    type = string
}

variable "frontend_port_name" {
    type = string
}

variable "frontend_ip_configuration_name" {
    type = string
}

variable "http_setting_name" {
    type = string
}

variable "listener_name" {
    type = string
}

variable "request_routing_rule_name" {
    type = string
}

variable "redirect_configuration_name" {
    type = string
}

variable "default_app_hostname" {
  type = string
}
variable "webapp" {
  type = string
}