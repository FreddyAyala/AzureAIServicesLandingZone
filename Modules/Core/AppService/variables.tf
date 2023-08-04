variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "subnet_id" {
  description = "The resource id of the subnet for vnet association"
  default     = null
}

variable "app_service_plan_name" {
  description = "Specifies the name of the App Service Plan component"
  default     = ""
}

variable "service_plan" {
  description = "Definition of the dedicated plan to use"
  type = object({
    kind             = string
    size             = string
    capacity         = optional(number)
    tier             = string
    per_site_scaling = optional(bool)
  })
}


variable "app_service_name" {
  description = "Specifies the name of the App Service."
  default     = ""
}

variable "app_settings" {
  description = "A key-value pair of App Settings."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "Site configuration for Application Service"
  type        = any
  default     = {}
}

variable "ips_allowed" {
  description = "IPs restriction for App Service to allow specific IP addresses or ranges"
  type        = list(string)
  default     = []
}

variable "subnet_ids_allowed" {
  description = "Allow Specific Subnets for App Service"
  type        = list(string)
  default     = []
}

variable "service_tags_allowed" {
  description = "Restrict Service Tags for App Service"
  type        = list(string)
  default     = []
}

variable "scm_ips_allowed" {
  description = "SCM IP restrictions for App service"
  type        = list(string)
  default     = []
}

variable "scm_subnet_ids_allowed" {
  description = "Restrict SCM Subnets for App Service"
  type        = list(string)
  default     = []
}

variable "scm_service_tags_allowed" {
  description = "Restrict SCM Service Tags for App Service"
  type        = list(string)
  default     = []
}

variable "enable_auth_settings" {
  description = "Specifies the Authenication enabled or not"
  default     = false
}

variable "default_auth_provider" {
  description = "The default provider to use when multiple providers have been set up. Possible values are `AzureActiveDirectory`, `Facebook`, `Google`, `MicrosoftAccount` and `Twitter`"
  default     = "AzureActiveDirectory"
}

variable "unauthenticated_client_action" {
  description = "The action to take when an unauthenticated client attempts to access the app. Possible values are `AllowAnonymous` and `RedirectToLoginPage`"
  default     = "RedirectToLoginPage"
}

variable "token_store_enabled" {
  description = "If enabled the module will durably store platform-specific security tokens that are obtained during login flows"
  default     = false
}

variable "active_directory_auth_setttings" {
  description = "Acitve directory authentication provider settings for app service"
  type        = any
  default     = {}
}

variable "enable_client_affinity" {
  description = "Should the App Service send session affinity cookies, which route client requests in the same session to the same instance?"
  default     = false
}

variable "enable_client_certificate" {
  description = "Does the App Service require client certificates for incoming requests"
  default     = false
}

variable "enable_https" {
  description = "Can the App Service only be accessed via HTTPS?"
  default     = false
}

variable "enable_backup" {
  description = "bool to to setup backup for app service "
  default     = false
}

variable "storage_container_name" {
  description = "The name of the storage container to keep backups"
  default     = null
}

variable "backup_settings" {
  description = "Backup settings for App service"
  type = object({
    name                     = string
    enabled                  = bool
    storage_account_url      = optional(string)
    frequency_interval       = number
    frequency_unit           = optional(string)
    retention_period_in_days = optional(number)
    start_time               = optional(string)
  })
  default = {
    enabled                  = false
    name                     = "DefaultBackup"
    frequency_interval       = 1
    frequency_unit           = "Day"
    retention_period_in_days = 1
  }
}

variable "connection_strings" {
  description = "Connection strings for App Service"
  type        = list(map(string))
  default     = []
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned"
  default     = null
}

variable "storage_mounts" {
  description = "Storage account mount points for App Service"
  type        = list(map(string))
  default     = []
}

variable "custom_domains" {
  description = "Custom domains with SSL binding and SSL certificates for the App Service. Getting the SSL certificate from an Azure Keyvault Certificate Secret or a file is possible."
  type        = map(map(string))
  default     = null
}

variable "storage_account_name" {
  description = "The name of the azure storage account"
  default     = ""
}

variable "password_end_date" {
  description = "The relative duration or RFC3339 rotation timestamp after which the password expire"
  default     = null
}

variable "password_rotation_in_years" {
  description = "Number of years to add to the base timestamp to configure the password rotation timestamp. Conflicts with password_end_date and either one is specified and not the both"
  default     = 2
}

variable "application_insights_enabled" {
  description = "Specify the Application Insights use for this App Service"
  default     = true
}

variable "application_insights_id" {
  description = "Resource ID of the existing Application Insights"
  default     = null
}

variable "app_insights_name" {
  description = "The Name of the application insights"
  default     = ""
}

variable "application_insights_type" {
  description = "Specifies the type of Application Insights to create. Valid values are `ios` for iOS, `java` for Java web, `MobileCenter` for App Center, `Node.JS` for Node.js, `other` for General, `phone` for Windows Phone, `store` for Windows Store and `web` for ASP.NET."
  default     = "web"
}

variable "retention_in_days" {
  description = "Specifies the retention period in days. Possible values are `30`, `60`, `90`, `120`, `180`, `270`, `365`, `550` or `730`"
  default     = 90
}

variable "disable_ip_masking" {
  description = "By default the real client ip is masked as `0.0.0.0` in the logs. Use this argument to disable masking and log the real client ip"
  default     = false
}

variable "enable_vnet_integration" {
  description = "Manages an App Service Virtual Network Association"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
