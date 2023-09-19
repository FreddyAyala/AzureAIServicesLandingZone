module "private_link_dns_integration" {

  source                       = "../Modules/Core/DNS/azure-private-endpoint-dns-integration"
  location                     = var.location
  resource_group_dns_name      = module.connectivity.dns_resource_group_name
  user_assigned_identity_name  = "dns-remediation-managed-identity"
  scope_management_group       = var.scope_management_group
  deny_prive_dns_zone_creation = false
  json_policies_file           = "${path.module}/private-zones.json"
  depends_on                   = [module.connectivity]
  providers = {
    azurerm = azurerm.connectivity
  }
}


module "private_dns_link" {
  source              = "../Modules/Core/DNS/private-dns-vnet-link"
  resource_group_name = module.connectivity.dns_resource_group_name
  vnets_to_associate  = [values(values(module.connectivity.module.azurerm_virtual_network)[0])[0].id]
  json_policies_file  = "${path.module}/private-zones.json"

  providers = {
    azurerm = "azurerm.connectivity"
  }

}



/*output "dns2" {
  description = "all the outputs of connectivty module"
  value       = module.connectivity.test2
}*/