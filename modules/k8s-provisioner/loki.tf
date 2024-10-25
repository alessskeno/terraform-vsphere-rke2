# https://grafana.com/docs/loki/latest/get-started/
# https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed
# https://grafana.com/docs/loki/latest/configure/#schema_config

resource "kubernetes_namespace" "loki" {
  count = var.loki_enabled ? 1 : 0
  metadata {
    name = "loki"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "loki" {
  count      = var.loki_enabled ? 1 : 0
  depends_on = [helm_release.longhorn, kubernetes_secret.loki_domain_tls]

  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = kubernetes_namespace.loki[0].metadata[0].name


  set {
    name  = "ingester.autoscaling.enabled"
    value = true
  }

  set {
    name  = "ingester.autoscaling.targetMemoryUtilizationPercentage"
    value = 60
  }

  set {
    name  = "distributor.autoscaling.enabled"
    value = true
  }

  set {
    name  = "distributor.autoscaling.targetMemoryUtilizationPercentage"
    value = 60
  }

  set {
    name  = "querier.autoscaling.enabled"
    value = true
  }

  set {
    name  = "querier.autoscaling.targetMemoryUtilizationPercentage"
    value = 60
  }

  set {
    name  = "queryFrontend.autoscaling.enabled"
    value = true
  }

  set {
    name  = "queryFrontend.autoscaling.targetMemoryUtilizationPercentage"
    value = 60
  }

  set {
    name  = "gateway.autoscaling.enabled"
    value = true
  }

  set {
    name  = "gateway.deploymentStrategy.type"
    value = "Recreate"
  }

  set {
    name  = "ruler.enabled"
    value = true
  }

  set {
    name  = "gateway.autoscaling.targetMemoryUtilizationPercentage"
    value = 60
  }

  values = [
    yamlencode(local.loki_values)
  ]
}

resource "kubernetes_secret" "loki_domain_tls" {
  count = var.loki_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.loki[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}

locals {
  loki_values = {
    fullnameOverride = "loki"
    loki = {
      config = file("${path.root}/files/configurations/loki-config.yaml")
    }
    global = {
      clusterDomain = "cluster.local"
      dnsService    = "rke2-coredns-rke2-coredns"
    }
    ingester = {
      autoscaling = {
        enabled     = true
        minReplicas = 1
        maxReplicas = 3
      }
      persistence = {
        enabled = true
        claims  = [
          {
            name         = "data"
            size         = "5Gi"
            storageClass = "longhorn"
          }
        ]
      }
      resources = {
        requests = {
          cpu    = "50m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
    distributor = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
    querier = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
    queryFrontend = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
    gateway = {
      ingress = {
        enabled = false
        labels  = local.default_labels
        hosts   = [
          {
            host  = local.loki_domain
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
        tls = [
          {
            hosts      = ["*.${var.domain}"]
            secretName = "tls-domain"
          }
        ]
      }
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
  }
}