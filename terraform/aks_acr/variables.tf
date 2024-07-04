variable "RESOURCE_GROUP_NAME" {
    description = "Resource group name"
    default = "Mustafa_Candidate"
  
}

variable "LOCATION" {
    description = "Location of the resource"
    default = "East US"
  
}

variable "client_id" {
  description = "The Client ID of the Service Principal."
  type        = string
}

variable "client_secret" {
  description = "The Client Secret of the Service Principal."
  type        = string
}

variable "subscription_id" {
  description = "The Subscription ID for Azure."
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID for Azure."
  type        = string
}






