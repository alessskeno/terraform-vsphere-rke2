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
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}

resource "helm_release" "rabbitmq" {
  count      = var.rabbitmq_enabled ? 1 : 0
  name       = "mb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  namespace  = kubernetes_namespace.rabbitmq[0].metadata[0].name
  version    = var.rabbitmq_version

  values = [
    yamlencode(local.rabbitmq_values)
  ]
}

locals {
  rabbitmq_values = {
    replicaCount = local.prod_env ? 2 : 1
    updateStrategy = {
      type = "RollingUpdate"
    }
    clustering = {
      forceBoot = true
    }
    topologySpreadConstraints = local.geo_redundant_tsc
    metrics = {
      enabled = true
    }
    persistence = {
      enabled      = true
      storageClass = var.storage_class_name
      size         = local.prod_env ? "8Gi" : "2Gi"
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      tls              = true
      existingSecret   = "rabbitmq-tls"
      pathType         = "Prefix"
      path             = "/"
      hostname         = local.rabbitmq_domain
      annotations = {
        "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
        "cert-manager.io/cluster-issuer"                 = kubectl_manifest.cluster_ca_issuer[0].name
        "cert-manager.io/common-name"                    = local.rabbitmq_domain
        "cert-manager.io/subject-organization"           = var.domain
      }
    }
  }
}

