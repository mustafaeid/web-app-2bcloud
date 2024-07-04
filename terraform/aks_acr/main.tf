data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "key_vault" {
  name                = "keyvault-2bcloud"
  resource_group_name = var.RESOURCE_GROUP_NAME
}

output "vault_uri" {
  value = data.azurerm_key_vault.key_vault.vault_uri
}
# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "bcloudaks"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  dns_prefix          = "bcloudaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"

    upgrade_settings {
      max_surge = "10%"
      drain_timeout_in_minutes = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
  }  
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = "bcloudacr"
  resource_group_name      = var.RESOURCE_GROUP_NAME
  location                 = var.LOCATION
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_public_ip" "nginx_ingress_ip" {
  name                = "nginx-ingress-ip"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  allocation_method   = "Static"
  sku                 = "Standard"
}