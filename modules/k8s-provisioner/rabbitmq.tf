# https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq
# https://artifacthub.io/packages/helm/bitnami/rabbitmq

# We enable "clustering.forceBoot" , https://github.com/helm/charts/pull/9645#issuecomment-478638566
/*

The default username for the application is user and the password is randomly generated. You can obtain these
credentials from the created secret mb-rabbitmq

*/

resource "kubernetes_namespace" "rabbitmq" {
  count = var.rabbitmq_enabled ? 1 : 0
  metadata {
    name = "rabbitmq"
    labels = merge(local.default_labels, {
      istio-injection = "enabled"
    })
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "rabbitmq" {
  count      = var.rabbitmq_enabled ? 1 : 0
  name       = "mb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  namespace  = kubernetes_namespace.rabbitmq[0].metadata[0].name
  version    = var.rabbitmq_version
  lifecycle {
    ignore_changes = [

    ]
  }

  set {
    name  = "replicaCount"
    value = local.prod_env ? 4 : 1
  }

  set {
    name  = "updateStrategy.type"
    value = "RollingUpdate" #  must be 'RollingUpdate' or 'OnDelete'
  }

  set {
    name  = "clustering.forceBoot"
    value = true
  }

  values = [
    yamlencode(local.rabbitmq_values)
  ]
}

resource "kubernetes_secret" "rabbitmq_domain_tls" {
  count = var.rabbitmq_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.rabbitmq[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }
}

locals {
  rabbitmq_values = {
    topologySpreadConstraints = local.geo_redundant_tsc
    metrics = {
      enabled = true
    }
    persistence = {
      enabled      = true
      storageClass = "longhorn"
      size         = local.prod_env ? "8Gi" : "2Gi"
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      tls              = true
      existingSecret   = "tls-domain"
      pathType         = "Prefix"
      path             = "/"
      hostname         = local.rabbitmq_domain
      annotations = {
        "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      }
    }
  }
}

