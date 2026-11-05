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
##  modules/subnets/subnets.tf
##
##  Azure subnets inside an existing virtual network, one per map entry.
## ----------------------------------------------------------------------------

## Subnet Context
module "subnet_context" {
  for_each = module.context.enabled ? var.subnets : {}

  source  = "../null-context"
  context = module.context.self

  attributes = ["snet"]
  name       = each.key
}


## Subnets
resource "azurerm_subnet" "this" {
  for_each = module.context.enabled ? var.subnets : {}

  address_prefixes                              = each.value.address_prefixes
  default_outbound_access_enabled               = each.value.default_outbound_access_enabled
  name                                          = module.subnet_context[each.key].id
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  resource_group_name                           = var.resource_group_name
  service_endpoints                             = each.value.service_endpoints
  virtual_network_name                          = var.virtual_network_name

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        actions = delegation.value.actions
        name    = delegation.value.service_name
      }
    }
  }
}
