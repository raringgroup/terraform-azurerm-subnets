# subnets

Creates Azure subnets inside an existing virtual network, one per entry in the `subnets` map. Each subnet is named through the SevenPico context module using the map key.

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

## Module Priority

No SevenPico, SevenPicoForks or CloudPosse module exists for Azure subnets, so the module uses `azurerm_subnet` directly. Naming and the enabled flag come from the context module. `_context.tf` declares the root context (`SevenPico/context/null` `2.0.0`); child contexts use the local `../null-context` module.

## Inputs

All inputs are required (no defaults). Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`.

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | Resource group that holds the virtual network |
| virtual_network_name | `string` | Virtual network the subnets are created in |
| subnets | `map(object)` | Subnets keyed by name. Per subnet: `address_prefixes` (required), `default_outbound_access_enabled` (`false` makes a private subnet), `private_endpoint_network_policies`, `private_link_service_network_policies_enabled`, `service_endpoints`, `delegation` (`name`, `service_name`, `actions`) |

## Outputs

| Name | Description |
|------|-------------|
| ids | Map of subnet key to subnet ID |
| names | Map of subnet key to generated subnet name |
| address_prefixes | Map of subnet key to address prefixes |

## Usage

```hcl
terraform {
  source = "git::<repo-url>//modules/subnets?ref=subnets-v<version>"
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "vnet" {
  config_path = "../vnet"
}

inputs = {
  enabled     = true
  namespace   = "<namespace>"
  environment = "<environment>"
  stage       = "<stage>"
  name        = "<name>"

  resource_group_name  = dependency.resource_group.outputs.name
  virtual_network_name = dependency.vnet.outputs.name

  subnets = {
    "<subnet-key>" = {
      address_prefixes = ["<cidr>"]
    }
    "<delegated-subnet-key>" = {
      address_prefixes = ["<cidr>"]
      delegation = {
        name         = "<delegation-name>"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}
```

## License

Apache License 2.0. Copyright 2026 Raring Group LLC.
