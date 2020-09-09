terraform {
  required_providers {
    azure = {
      source = "terraform-providers/azure"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.13"
}
