
resource "random_string" "resourceToken" {
  length           = 10
  special          = false

}
module "app-service" {
  source  = "../../Modules/Core/AppService"
 

  # By default, this module will not create a resource group. Location will be same as existing RG.
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # set the argument to `create_resource_group = true` to create new resrouce group.
  resource_group_name   = "rg-azure-chatgpt-webapp"
  create_resource_group = true
  location = local.location

  # App service plan setttings and supported arguments. Default name used by module
  # To specify custom name use `app_service_plan_name` with a valid name.  
  # for Service Plans, see https://azure.microsoft.com/en-us/pricing/details/app-service/windows/  
  # App Service Plan for `Free` or `Shared` Tiers `use_32_bit_worker_process` must be set to `true`.
  service_plan = {
    kind = "Linux"
    size = "P0v3"
    tier = "Premium0V3"
    reserved=true
  }

  # App Service settings and supported arguments
  # Backup, connection_string, auth_settings, Storage for mounts are optional configuration
  app_service_name       = "azurechatgpt"
  enable_client_affinity = true

  # A `site_config` block to setup the application environment. 
  # Available built-in stacks (windows_fx_version) for web apps `az webapp list-runtimes`
  # Runtime stacks for Linux (linux_fx_version) based web apps `az webapp list-runtimes --linux`
  site_config = {
    always_on      = true
    linuxFxVersion = "node|18-lts"
    alwaysOn       = true
    appCommandLine = "node server.js"
  }

  # (Optional) A key-value pair of Application Settings
  app_settings = {
    AZURE_COSMOSEDB_URI                             = azurerm_cosmosdb_account.example.endpoint
    AZURE_COSMOSEDB_KEY                             = azurerm_cosmosdb_account.example.primary_key
    AZURE_OPENAI_API_KEY                            = module.openai.openai_primary_key
    AZURE_OPENAI_API_INSTANCE_NAME                  = module.openai.openai_name
    AZURE_OPENAI_API_DEPLOYMENT_NAME                = local.AI.open_ai.deployment["gpt-35-turbo"].model_name
    AZURE_OPENAI_API_VERSION                        = local.AI.open_ai.deployment["gpt-35-turbo"].model_version
    NEXTAUTH_SECRET                                 = "openai-app$-{local.resourceToken}"
    NEXTAUTH_URL                                    = "https://openai-app-${random_string.resourceToken.result}.azurewebsites.net"
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Java           = "1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }

  # The Backup feature in Azure App Service easily create app backups manually or on a schedule.
  # You can configure the backups to be retained up to an indefinite amount of time.
  # Azure storage account and container in the same subscription as the app that you want to back up. 
  # This module creates a Storage Container to keep the all backup items. 
  # Backup items - App configuration , File content, Database connected to your app
  enable_backup        = false
 

  # Regional VNet integration configuration
  # Enables you to place the back end of app in a subnet in virtual network in the same region
  enable_vnet_integration = true
  subnet_id               = lookup(module.vnet_ai.vnet_subnets_name_id, "snet_chatgpt")

  # By default App Insight resource is created by this module. 
  # Specify valid resource Id to `application_insights_id` to use existing App Insight
  # Specifies the type of Application by setting up `application_insights_type` with valid string
  # Specifies the retention period in days using `retention_in_days`. Default 90.
  # By default the real client ip is masked in the logs, to enable set `disable_ip_masking` to `true` 
  app_insights_name = "azchgptshared"
}
