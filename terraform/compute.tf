locals {
  vm_hosts = {
    frontend = {
      subnet_id = azurerm_subnet.frontend.id
    }
    backend = {
      subnet_id = azurerm_subnet.backend.id
    }
  }
}

resource "azurerm_public_ip" "vm" {
  for_each = local.vm_hosts

  name                = "pip-epicbook-${each.key}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "vm" {
  for_each = local.vm_hosts

  name                = "nic-epicbook-${each.key}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.vm_hosts

  name                = "vm-epicbook-${each.key}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/keys/vm_access.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.tier
  ]

  tags = merge(local.tags, {
    tier = each.key
  })
}
