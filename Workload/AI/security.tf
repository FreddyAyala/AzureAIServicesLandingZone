/*module "key_vault" {
  source = "./../../Modules/Core/Security/key_vault"

  client_name                   = local.Security.Keyvault.client_name
  name_suffix                   = local.Security.Keyvault.name_suffix
  environment                   = local.environment
  location                      = local.location
  resource_group_name           = local.Security.Keyvault.resource_group_name
  admin_objects_ids             = local.Security.Keyvault.admins
  logs_destinations_ids         = local.Security.Keyvault.logs_destinations_ids
  public_network_access_enabled = local.Security.Keyvault.public_network_access_enabled

  network_acls = local.Security.Keyvault.network_acls
  
  private_endpoint =local.Security.Keyvault.private_endpoint
  
  providers = {
    azurerm              = azurerm.ai,
    azurerm.connectivity = azurerm.connectivity
  }


}

*/

