locals {
  ssh_rules = [
    {
      name     = "Allow-SSH-Administrator"
      priority = 100
      port     = "22"
      source   = var.admin_cidr
      access   = "Allow"
    },
    {
      name     = "Allow-SSH-Agent"
      priority = 110
      port     = "22"
      source   = var.agent_cidr
      access   = "Allow"
    },
    {
      name     = "Deny-Other-SSH"
      priority = 120
      port     = "22"
      source   = "*"
      access   = "Deny"
    }
  ]

  tier_rules = {
    frontend = concat(local.ssh_rules, [
      {
        name     = "Allow-Public-HTTP"
        priority = 200
        port     = "80"
        source   = "Internet"
        access   = "Allow"
      }
    ])

    backend = concat(local.ssh_rules, [
      {
        name     = "Allow-Application-From-Frontend"
        priority = 200
        port     = tostring(var.backend_port)
        source   = azurerm_subnet.frontend.address_prefixes[0]
        access   = "Allow"
      },
      {
        name     = "Deny-Other-Application-Traffic"
        priority = 210
        port     = tostring(var.backend_port)
        source   = "*"
        access   = "Deny"
      }
    ])

    database = [
      {
        name     = "Allow-MySQL-From-Backend"
        priority = 100
        port     = "3306"
        source   = azurerm_subnet.backend.address_prefixes[0]
        access   = "Allow"
      },
      {
        name     = "Allow-MySQL-Service-Internal"
        priority = 110
        port     = "3306"
        source   = azurerm_subnet.database.address_prefixes[0]
        access   = "Allow"
      },
      {
        name     = "Deny-Other-MySQL-Traffic"
        priority = 200
        port     = "3306"
        source   = "*"
        access   = "Deny"
      }
    ]
  }

  tier_subnets = {
    frontend = azurerm_subnet.frontend.id
    backend  = azurerm_subnet.backend.id
    database = azurerm_subnet.database.id
  }
}

resource "azurerm_network_security_group" "tier" {
  for_each = local.tier_rules

  name                = "nsg-epicbook-${each.key}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = each.value

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = security_rule.value.access
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = security_rule.value.source
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "tier" {
  for_each = local.tier_subnets

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.tier[each.key].id
}
