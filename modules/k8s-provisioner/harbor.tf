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

  set {
    name  = "externalURL"
    value = "https://${local.harbor_domain}"
  }

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "updateStrategy.type"
    value = "Recreate"
  }

  set {
    name  = "persistence.persistentVolumeClaim.registry.size"
    value = "200Gi"
  }

  set {
    name  = "persistence.persistentVolumeClaim.database.size"
    value = "5Gi"
  }

  set {
    name  = "persistence.persistentVolumeClaim.jobservice.jobLog.size"
    value = "2Gi"
  }

  set {
    name  = "persistence.persistentVolumeClaim.redis.size"
    value = "2Gi"
  }

  set {
    name  = "persistence.persistentVolumeClaim.jobservice.jobLog.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name  = "persistence.persistentVolumeClaim.redis.accessMode"
    value = "ReadWriteOnce"
  }

  set_sensitive {
    name  = "database.internal.password"
    value = var.general_password
  }

  set_sensitive {
    name  = "harborAdminPassword"
    value = var.general_password
  }
  values = [
    yamlencode(local.harbor_values)
  ]

}

locals {
  harbor_values = {
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
          secretName = "tls-domain"
        }
      }
      ingress = {
        hosts = {
          core = local.harbor_domain
        }
        className = "nginx"
        annotations = {
          "ingress.kubernetes.io/ssl-redirect" = "true"
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

resource "kubernetes_secret" "harbor_domain_tls" {
  count = var.harbor_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.harbor[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}