# https://github.com/goharbor/harbor-helm

resource "kubernetes_namespace" "harbor" {
  count = var.harbor_enabled && var.longhorn_enabled ? 1 : 0
  metadata {
    name = "harbor"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "harbor" {
  depends_on = [helm_release.longhorn]

  count      = var.harbor_enabled && var.longhorn_enabled ? 1 : 0
  name       = "harbor"
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  namespace  = kubernetes_namespace.harbor[0].metadata[0].name
  version    = var.harbor_version

  values = [
    yamlencode(local.harbor_values)
  ]

}

locals {
  harbor_values = {
    externalURL = "https://${local.harbor_domain}"
    harborAdminPassword = var.general_password
    updateStrategy = {
      type = "Recreate"
    }
    portal = {
      affinity = local.az3_affinity_rule
    }
    core = {
      affinity = local.az3_affinity_rule
    }
    jobservice = {
      affinity = local.az3_affinity_rule
    }
    registry = {
      affinity = local.az3_affinity_rule
    }
    trivy = {
      enabled = true
      affinity = local.az3_affinity_rule
    }
    database = {
      internal = {
        affinity = local.az3_affinity_rule
        password = var.general_password
      }
    }
    redis = {
      internal = {
        affinity = local.az3_affinity_rule
      }
    }
    expose = {
      type = "ingress"
      tls = {
        enabled    = true
        certSource = "secret"
        secret = {
          secretName = "harbor-tls"
        }
      }
      ingress = {
        hosts = {
          core = local.harbor_domain
        }
        className = "nginx"
        annotations = {
          "ingress.kubernetes.io/ssl-redirect" = "true"
          "cert-manager.io/cluster-issuer"       = kubectl_manifest.cluster_ca_issuer[0].name
          "cert-manager.io/common-name"          = local.harbor_domain
          "cert-manager.io/subject-organization" = var.domain
        }
      }
    }
    persistence = {
      enabled = true
      persistentVolumeClaim = {
        registry = {
          size = "50Gi"
        }
        database = {
          size = "5Gi"
        }
        jobservice = {
          jobLog = {
            size = "2Gi"
            accessMode = "ReadWriteOnce"
          }
        }
        redis = {
          size = "2Gi"
          accessMode = "ReadWriteOnce"
        }

      }
    }
  }
}


module "harbor_provisioner" {
  depends_on = [helm_release.harbor]
  count             = var.harbor_enabled && var.harbor_provisioner ? 1 : 0
  source            = "./harbor-provisioner"
  namespaces        = var.namespaces
  general_password  = var.general_password
}