locals {
  location    = "westeurope"
  environment = "dev"

  ai_subscription           = var.ai_subscription
  connectivity_subscription = var.connectivity_subscription

  AI = {
    cognitive_service = {
      create_new_resource_group = false

      existing_resource_group_name     = "rg-cognitive-services" # Leave this empty since we are creating a new resource group
      existing_resource_group_location = local.location
    }

    cognitive_search = {
      create_new_resource_group = false

      existing_resource_group_name     = "rg-cognitive-services" # Leave this empty since we are creating a new resource group
      existing_resource_group_location = local.location
      sku                              = "standard"
      replica_count                    = 2
      partition_count                  = 2
    }

    open_ai = {
      resource_group_name = "my-resource-group"
      identity={
        type="SystemAssigned"
        
      }
      private_endpoint = {

        "pe_endpoint" = {
          private_dns_entry_enabled         = true
          link_dns_zone_virtual_network     = true
          link_dns_zone_virtual_network_hub = true
          virtual_network_hub_id            = local.hub_vnet_id
          is_manual_connection              = false
          name                              = "pe_one"
          private_service_connection_name   = "pe_one_connection"
          subnet_name                       = "snet_ai"
          vnet_name                         = "vnet-ai-lz" # Replace with the actual VNet name
          vnet_rg_name                      = "rg-network" # Replace with the actual VNet resource group name
        }
      }

      deployment = {
        "gpt-35-turbo" = {
          name          = "gpt-35-turbo2"
          model_format  = "OpenAI"
          model_name    = "gpt-35-turbo"
          model_version = "0301"
          scale_type    = "Standard"
        }
      }
    }
  }

  Hub_Values = {

    hub_resource_group_name  = local.Network.hub_values[4]
    hub_virtual_network_name = local.Network.hub_values[8]
  }

  hub_vnet_id = var.hub_vnet_id

  Network = {

    hub_nva_static_ip = "10.100.0.4"
    hub_vnet_name     = "es-hub-westeurope"

    hub_values = split("/", local.hub_vnet_id)


    vnet-ai-lz = {
      resource_group_name           = "rg-network"
      virtual_network_address_space = ["10.52.0.0/16"]
      virtual_network_name          = "vnet-ai-lz"
      #snets
      snet_services_address_prefixes  = ["10.52.0.0/23"]
      snet_services_service_endpoints = ["Microsoft.KeyVault"]

      snet_web_address_prefixes  = ["10.52.2.0/23"]
      snet_web_service_endpoints = ["Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]

      snet_database_address_prefixes  = ["10.52.4.0/22"]
      snet_database_service_endpoints = []

      snet_ai_address_prefixes  = ["10.52.8.0/21"]
      snet_ai_service_endpoints = ["Microsoft.CognitiveServices"]

      snet_ag_address_prefixes  = ["10.52.16.0/23"]
      snet_ag_service_endpoints = []

      snet_chatgpt_address_prefixes  = ["10.52.18.0/23"]
      snet_chatgpt_service_endpoints = []



    }
  }

  Security = {
    Keyvault = {
      # Values for the variables used in the module call
      client_name                   = "my-kv"
      name_suffix                   = "my-suffix"
      public_network_access_enabled = true

      # Example of providing network_acls as a separate variable
      network_acls = {
        ip_rules       = ["0.0.0.0/0"]
        bypass         = "AzureServices"
        default_action = "Allow" # Allow public access
      }

      # Provide the value for azurerm_resource_group.rg_shared_test.name
      resource_group_name = "my-resource-group"

      # Other variables if needed
      admins = [
      ]

      logs_destinations_ids = []

     
    }
  }


}
