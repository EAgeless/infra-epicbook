data "azurerm_client_config" "current" {}

locals {
  state_storage_name = "stepicbook${substr(sha256(data.azurerm_client_config.current.subscription_id), 0, 12)}"
}

resource "azurerm_resource_group" "state" {
  name     = "rg-epicbook-tfstate"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "state" {
  name                     = local.state_storage_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.tags, {
    purpose = "terraform-state"
  })
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}
