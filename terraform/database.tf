data "azurerm_client_config" "deployment" {}

locals {
  mysql_server_name = "mysql-epicbook-${substr(sha256(data.azurerm_client_config.deployment.subscription_id), 0, 12)}"
}

resource "azurerm_mysql_flexible_server" "app" {
  name                = local.mysql_server_name
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  sku_name              = "B_Standard_B1ms"
  version               = "8.0.21"
  backup_retention_days = 7

  delegated_subnet_id   = azurerm_subnet.database.id
  private_dns_zone_id   = azurerm_private_dns_zone.mysql.id
  public_network_access = "Disabled"

  storage {
    size_gb           = 20
    auto_grow_enabled = true
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql,
    azurerm_subnet_network_security_group_association.tier
  ]

  tags = local.tags
}
