locals {
  tags = {
    project    = "epicbook"
    purpose    = "pipeline-agent"
    managed_by = "terraform"
  }
}

resource "azurerm_resource_group" "agent" {
  name     = "rg-epicbook-agent"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "agent" {
  name                = "vnet-epicbook-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name
  address_space       = ["10.50.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "agent" {
  name                 = "snet-agent"
  resource_group_name  = azurerm_resource_group.agent.name
  virtual_network_name = azurerm_virtual_network.agent.name
  address_prefixes     = ["10.50.1.0/24"]
}

resource "azurerm_network_security_group" "agent" {
  name                = "nsg-epicbook-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name

  security_rule {
    name                       = "Allow-SSH-Administrator"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_public_ip" "agent" {
  name                = "pip-epicbook-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "agent" {
  name                = "nic-epicbook-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.agent.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.agent.id
  }

  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "agent" {
  network_interface_id      = azurerm_network_interface.agent.id
  network_security_group_id = azurerm_network_security_group.agent.id
}

resource "azurerm_linux_virtual_machine" "agent" {
  name                = "vm-epicbook-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.agent.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
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
    azurerm_network_interface_security_group_association.agent
  ]

  tags = local.tags
}
