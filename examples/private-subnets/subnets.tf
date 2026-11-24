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
##  examples/private-subnets/subnets.tf
##
##  Private (no internet) tier: a data subnet and a private endpoint subnet,
##  both with default outbound access turned off. Only service endpoints and
##  private endpoints reach other Azure services.
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


## Private Subnets
module "subnets" {
  source  = "../../"
  context = module.context.self

  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  subnets = {
    "data" = {
      address_prefixes                = ["10.0.10.0/24"]
      default_outbound_access_enabled = false
      service_endpoints               = ["Microsoft.AzureCosmosDB", "Microsoft.Storage"]
    }
    "private-endpoints" = {
      address_prefixes                              = ["10.0.11.0/24"]
      default_outbound_access_enabled               = false
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
    }
  }
}
