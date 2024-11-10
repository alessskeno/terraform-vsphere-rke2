# https://grafana.com/docs/loki/latest/get-started/
# https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed
# https://grafana.com/docs/loki/latest/configure/#schema_config

resource "kubernetes_namespace" "loki" {
  count = var.loki_enabled ? 1 : 0
  metadata {
    name = "loki"
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}

resource "helm_release" "loki" {
  count = var.loki_enabled ? 1 : 0
  depends_on = [helm_release.longhorn]

  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = kubernetes_namespace.loki[0].metadata[0].name
  version    = var.loki_version

  values = [
    yamlencode(local.loki_values)
  ]
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
    ruler = {
      enabled = true
    }
    ingester = {
      autoscaling = {
        targetMemoryUtilizationPercentage = 60
        enabled                           = true
        minReplicas                       = 1
        maxReplicas                       = 3
      }
      persistence = {
        enabled = true
        claims = [
          {
            name         = "data"
            size         = "5Gi"
            storageClass = var.storage_class_name
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
      autoscaling = {
        targetMemoryUtilizationPercentage = 60
        enabled                           = true
        minReplicas                       = 1
        maxReplicas                       = 3
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
    querier = {
      autoscaling = {
        targetMemoryUtilizationPercentage = 60
        enabled                           = true
        minReplicas                       = 1
        maxReplicas                       = 3
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
    queryFrontend = {
      autoscaling = {
        targetMemoryUtilizationPercentage = 60
        enabled                           = true
        minReplicas                       = 1
        maxReplicas                       = 3
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
    gateway = {
      deploymentStrategy = {
        type = "Recreate"
      }
      autoscaling = {
        targetMemoryUtilizationPercentage = 60
        enabled                           = true
        minReplicas                       = 1
        maxReplicas                       = 3
      }
      ingress = {
        enabled = false
        labels  = local.default_labels
        annotations = {
          "cert-manager.io/cluster-issuer"       = kubectl_manifest.cluster_ca_issuer[0].name
          "cert-manager.io/common-name"          = local.loki_domain
          "cert-manager.io/subject-organization" = var.domain
        }
        hosts = [
          {
            host = local.loki_domain
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
            hosts = [local.loki_domain]
            secretName = "loki-tls"
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