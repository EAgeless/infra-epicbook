output "state_resource_group" {
  description = "Resource group containing Terraform state storage."
  value       = azurerm_resource_group.state.name
}

output "state_storage_account" {
  description = "Storage account for the Terraform backend."
  value       = azurerm_storage_account.state.name
}

output "state_container" {
  description = "Private container containing Terraform state blobs."
  value       = azurerm_storage_container.state.name
}
