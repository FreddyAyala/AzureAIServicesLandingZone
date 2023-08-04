resource "azurerm_resource_group" "cognitive" {
  location = local.location
  name     = "rg-cognitive-services"
  provider = azurerm
}
module "cognitive_services" {
  source                           = "../../Modules/AI/cognitive_services" # Replace this with the actual path to your module
  create_new_resource_group        = local.AI.cognitive_service.create_new_resource_group
  resource_group_name              = azurerm_resource_group.cognitive.name
  resource_group_location          = local.location
  existing_resource_group_name     = local.AI.cognitive_service.existing_resource_group_name
  existing_resource_group_location = local.AI.cognitive_service.existing_resource_group_location

   providers = {
    azurerm              = azurerm
   }
}

module "cognitive_search" {
  source = "../../Modules/AI/cognitive_search" # Replace this with the actual path to the directory containing the module

  create_new_resource_group        = local.AI.cognitive_search.create_new_resource_group
  resource_group_name              = azurerm_resource_group.cognitive.name
  resource_group_location          = local.location
  existing_resource_group_name     = local.AI.cognitive_search.existing_resource_group_name
  existing_resource_group_location = local.AI.cognitive_search.existing_resource_group_location
  sku                              = local.AI.cognitive_search.sku
  replica_count                    = local.AI.cognitive_search.replica_count
  partition_count                  = local.AI.cognitive_search.partition_count
  
}

resource "azurerm_resource_group" "this" {
  location = local.location
  name     = "rg-openai"
  provider = azurerm
}

module "openai" {
  source = "../../Modules/AI/open_ai"

  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  private_endpoint    = local.AI.open_ai.private_endpoint
  deployment          = local.AI.open_ai.deployment
  sku_name ="S0"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  depends_on = [
    module.vnet_ai,
    azurerm_resource_group.this,
  ]
}






