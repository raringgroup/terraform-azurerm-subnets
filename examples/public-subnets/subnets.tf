## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------
##
##  examples/public-subnets/subnets.tf
##
##  Public (internet-facing) tier: a subnet delegated to App Service for
##  regional VNet integration and a dedicated subnet for an Application
##  Gateway. Both keep default outbound internet access.
## ----------------------------------------------------------------------------

## Resource Group
resource "azurerm_resource_group" "this" {
  location = var.region
  name     = "${module.context.id}-rg"
  tags     = module.context.tags
}


## Virtual Network
resource "azurerm_virtual_network" "this" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "${module.context.id}-vnet"
  resource_group_name = azurerm_resource_group.this.name
  tags                = module.context.tags
}


## Public Subnets
module "subnets" {
  source  = "../../"
  context = module.context.self

  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  subnets = {
    "web" = {
      address_prefixes                = ["10.0.1.0/24"]
      default_outbound_access_enabled = true
      service_endpoints               = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegation = {
        name         = "app-service"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    "gateway" = {
      address_prefixes                = ["10.0.2.0/24"]
      default_outbound_access_enabled = true
    }
  }
}
