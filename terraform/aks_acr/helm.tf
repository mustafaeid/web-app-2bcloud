resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  create_namespace = true

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.resourceGroup"
    value = var.RESOURCE_GROUP_NAME
  }

  set {
    name  = "azure.subscriptionId"
    value = data.azurerm_client_config.current.subscription_id
  }

  set {
    name  = "azure.tenantId"
    value = data.azurerm_client_config.current.tenant_id
  }

  set {
    name  = "azure.clientId"
    value = data.azurerm_client_config.current.client_id
  }

  set {
    name  = "azure.secretKey"
    value = var.client_secret
  }

}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.nginx_ingress_ip.ip_address
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = var.RESOURCE_GROUP_NAME
  }
}

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  namespace  = "redis"
  create_namespace = true

  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "cluster.nodes"
    value = "3"
  }

  set {
    name  = "sentinel.enabled"
    value = "true"
  }
}
