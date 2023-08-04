
# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.1.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = local.location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm

  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  

  deploy_connectivity_resources    = true
  deploy_core_landing_zones = false

  subscription_id_connectivity     = local.connectivity_subscription
  configure_connectivity_resources = local.configure_connectivity_resources
 
}
