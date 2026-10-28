resource "azurerm_private_dns_zone" "mysql" {
  name                = "epicbook.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "link-epicbook-mysql"
  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.app.id
  registration_enabled  = false
  tags                  = local.tags
}
