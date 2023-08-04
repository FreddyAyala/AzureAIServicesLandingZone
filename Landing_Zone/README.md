To deploy first deploy the spoke networks

terraform apply -target="module.vnet_ai"

then you can deploy the rest

terraform apply

This happens because for the landing zone to work we need to associate the dns zones and make peering. The Azure Terraform Landing Zone module requires to have static values here:

locals {
  location                  = "westeurope"
  root_id                   = "dea6f2e5-c64a-4e29-8a83-5f1eb4136640"
  root_name                 = "Tenant Root Group"
  environment               = "dev"
  connectivity_subscription = "8dfc81b4-9732-4b10-88ad-07cf9a644863"

  spoke_networks = {
    AI = {
      resource_group_name           = "rg-network"
      virtual_network_address_space = ["10.52.0.0/16"]
      virtual_network_name          = "vnet"
      #snets
      snet_services_address_prefixes  = ["10.52.0.0/23"]
      snet_services_service_endpoints = ["Microsoft.KeyVault"]

      snet_web_address_prefixes  = ["10.52.2.0/23"]
      snet_web_service_endpoints = []

      snet_database_address_prefixes  = ["10.52.4.0/22"]
      snet_database_service_endpoints = []

      snet_ai_address_prefixes  = ["10.52.8.0/21"]
      snet_ai_service_endpoints = ["Microsoft.CognitiveServices"]

    }
  }

  configure_connectivity_resources = {
    
    ...
      dns = {
        enabled = true
        config = {
          location = local.location
          enable_private_link_by_service = {

            azure_api_management                 = true
           ...
          }
          private_link_locations = [
            local.location
          ]
          public_dns_zones                                       = []
          private_dns_zones                                      = ["privatelink.keyvault.core.windows.net", "privatelink.openai.core.windows.net"]
          enable_private_dns_zone_virtual_network_link_on_hubs   = true
          enable_private_dns_zone_virtual_network_link_on_spokes = false
          virtual_network_resource_ids_to_link                   = [module.vnet_ai.vnet_id] <=== Here
        }
      }
    }

    So if we want to dynamically attach the spokes to the DNS zones and peerings we have no choice but to divide this in two steps
    
Otherwise we get the error:

Error: Invalid for_each argument
│
│   on .terraform\modules\enterprise_scale\resources.connectivity.tf line 493, in resource "azurerm_private_dns_zone_virtual_network_link" "connectivity":
│  493:   for_each = local.azurerm_private_dns_zone_virtual_network_link_connectivity
│     ├────────────────
│     │ local.azurerm_private_dns_zone_virtual_network_link_connectivity will be known only after apply
│
│ The "for_each" map includes keys derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that will identify the instances of this      
│ resource.
│
│ When working with unknown values in for_each, it's better to define the map keys statically in your configuration and place apply-time results only in the map values.
│
│ Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends on, and then apply a second time to fully converge.


terraform apply -auto-approve="true" -target="module.vnet_ai" -lock=false
terraform apply -auto-approve="true" -lock=false