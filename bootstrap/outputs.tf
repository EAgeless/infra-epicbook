output "agent_public_ip" {
  description = "Agent public IP for administration and SSH allowlisting."
  value       = azurerm_public_ip.agent.ip_address
}

output "agent_username" {
  value = var.admin_username
}

output "agent_resource_group" {
  value = azurerm_resource_group.agent.name
}
