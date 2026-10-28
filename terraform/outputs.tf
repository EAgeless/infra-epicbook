output "app_public_ip" {
  description = "Frontend public IP for browser access."
  value       = azurerm_public_ip.vm["frontend"].ip_address
}

output "backend_ansible_host" {
  description = "Backend public management IP for restricted Ansible SSH."
  value       = azurerm_public_ip.vm["backend"].ip_address
}

output "backend_private_ip" {
  description = "Backend private address used by Nginx."
  value       = azurerm_network_interface.vm["backend"].private_ip_address
}

output "mysql_fqdn" {
  description = "Private MySQL server hostname."
  value       = azurerm_mysql_flexible_server.app.fqdn
}
