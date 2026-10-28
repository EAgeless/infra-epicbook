terraform {
  backend "azurerm" {
    resource_group_name  = "rg-epicbook-tfstate"
    storage_account_name = "stepicbookc68b52c999f7"
    container_name       = "tfstate"
    key                  = "epicbook-infra.tfstate"

    use_azuread_auth = true
  }
}
