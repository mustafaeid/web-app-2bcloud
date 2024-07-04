resource "random_password" "mysecret" {
 length           = 64
}

resource "azurerm_key_vault_secret" "mysecret" {
 name         = "mysecret"
 value        = random_password.mysecret.result
 key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secrets" "secrets" {
 key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "helm_release" "aks_secret_provider" {
 name    = "aks-secret-provider"
 chart   = "./aks-secret-provider"
 version = "0.0.1"
 values = [yamlencode({
   vaultName = data.azurerm_key_vault.key_vault.name
   tenantId  = data.azurerm_key_vault.key_vault.tenant_id
   clientId  = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
   secrets   = data.azurerm_key_vault_secrets.secrets.names # secrets to expose         
 })]
 force_update = true
}

