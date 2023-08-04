# AI Spoke
resource "azurerm_resource_group" "network" {
  location = local.location
  name     = local.Network.vnet-ai-lz.resource_group_name
}

resource "azurerm_route_table" "spoke_to_hub" {
  name                          = "rt_spoke_to_hub"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.network.name
  disable_bgp_route_propagation = false

  route {
    name                   = "route_spoke_to_hub"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.Network.hub_nva_static_ip
  }


}

#apim NSG

resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "nsg-apim"
  location            = local.location
  resource_group_name = azurerm_resource_group.apim.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = lookup(module.vnet_ai.vnet_subnets_name_id, "snet_web")
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

# Rule 1: Inbound TCP rule for Client communication to API Management
resource "azurerm_network_security_rule" "rule_stv2" {
  name                        = "rule-stv2"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  description                 = "Client communication to API Management"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

resource "azurerm_network_security_rule" "rule_stv3_1" {
  name                        = "rule-stv3_1"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"           # Corrected to the required destination port (3443)
  source_address_prefix       = "ApiManagement"  # Required source service tag
  destination_address_prefix  = "VirtualNetwork" # Required destination service tag
  description                 = "Management endpoint for Azure portal and PowerShell"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

# Rule 3: Inbound TCP rule for Azure Infrastructure Load Balancer
resource "azurerm_network_security_rule" "rule_lb" {
  name                        = "rule-lb"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6390"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureLoadBalancer"
  description                 = "Azure Infrastructure Load Balancer"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

# Rule 2: Inbound TCP rule for Management endpoint for Azure portal and PowerShell
resource "azurerm_network_security_rule" "rule_stv1" {
  name                        = "rule-stv1"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "*"
  destination_address_prefix  = "ApiManagement"
  description                 = "Management endpoint for Azure portal and PowerShell"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}






resource "azurerm_network_security_rule" "rule_stv3" {
  name                        = "rule-stv3"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "*"
  destination_address_prefix  = "ApiManagement"
  description                 = "Management endpoint for Azure portal and PowerShell"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}


# Rule 4: Outbound TCP rule for Dependency on Azure Storage
resource "azurerm_network_security_rule" "rule_storage" {
  name                        = "rule-storage"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Storage"
  description                 = "Dependency on Azure Storage"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

# Rule 5: Outbound TCP rule for Access to Azure SQL endpoints
resource "azurerm_network_security_rule" "rule_sql" {
  name                        = "rule-sql"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "SQL"
  description                 = "Access to Azure SQL endpoints"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

# Rule 6: Outbound TCP rule for Access to Azure Key Vault
resource "azurerm_network_security_rule" "rule_kv" {
  name                        = "rule-kv"
  priority                    = 202
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  description                 = "Access to Azure Key Vault"
  resource_group_name         = azurerm_resource_group.apim.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

#Route table APIM
resource "azurerm_route_table" "rt_web" {
  name                = "route-table-web"
  resource_group_name = azurerm_resource_group.network.name
  location            = local.location
}

resource "azurerm_route" "rt_api_mgmt" {
  name                = "route-apim"
  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.rt_web.name
  address_prefix      = "ApiManagement"
  next_hop_type       = "Internet"

}





#VNET

module "vnet_ai" {
  source  = "Azure/subnets/azurerm"
  version = "1.0.0"

  resource_group_name = azurerm_resource_group.network.name

  subnets = {
    snet_services = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_services_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_services_service_endpoints
      route_table = {
        id = azurerm_route_table.spoke_to_hub.id
      }
    }
    snet_web = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_web_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_web_service_endpoints
      route_table = {
        id = azurerm_route_table.rt_web.id
      }
     
    }

    snet_chatgpt = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_chatgpt_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_chatgpt_service_endpoints
      route_table = {
        id = azurerm_route_table.rt_web.id
      }
       delegations = [
        {
          name = "Microsoft.Web/serverFarms"
          service_delegation = {
            name = "Microsoft.Web/serverFarms"           
          }
        }
      ]
    }

    snet_database = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_database_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_database_service_endpoints
      route_table = {
        id = azurerm_route_table.spoke_to_hub.id
      }
    }

    snet_ai = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_ai_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_ai_service_endpoints
      route_table = {
        id = azurerm_route_table.spoke_to_hub.id
      }
    }

    snet_ag = {
      address_prefixes  = local.Network.vnet-ai-lz.snet_ag_address_prefixes
      service_endpoints = local.Network.vnet-ai-lz.snet_ag_service_endpoints
     
    }
  }

  virtual_network_address_space = local.Network.vnet-ai-lz.virtual_network_address_space
  virtual_network_location      = local.location
  virtual_network_name          = local.Network.vnet-ai-lz.virtual_network_name

}

resource "azurerm_virtual_network_peering" "peering-ai-to-hub" {
  name                         = "peering-ai-to-hub"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = local.Network.vnet-ai-lz.virtual_network_name
  remote_virtual_network_id    = local.hub_vnet_id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peering-hub-to-ai" {
  name                         = "peering-hub-to-ai"
  resource_group_name          = local.Hub_Values.hub_resource_group_name
  virtual_network_name         = local.Hub_Values.hub_virtual_network_name
  remote_virtual_network_id    = module.vnet_ai.vnet_id
  allow_virtual_network_access = true
  provider                     = azurerm.connectivity
}
