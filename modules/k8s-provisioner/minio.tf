resource "kubernetes_namespace" "minio" {
  count = local.prod_env && var.minio_enabled ? 1 : 0
  metadata {
    name   = "minio"
    labels = local.default_labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "helm_release" "minio" {
  count = local.prod_env && var.minio_enabled ? 1 : 0

  depends_on = [
    helm_release.longhorn
  ]

  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  namespace  = kubernetes_namespace.minio[0].metadata[0].name

  set {
    name  = "persistence.storageClass"
    value = var.storage_class_name
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  set {
    name  = "mode"
    value = "distributed"
  }

  set {
    name  = "statefulset.replicaCount"
    value = "2"
  }

  set {
    name  = "statefulset.drivesPerNode"
    value = "4"
  }

  set {
    name  = "auth.rootUser"
    value = var.general_user
  }

  set {
    name  = "auth.rootPassword"
    value = var.general_password
  }

  values = [
    yamlencode(local.minio_values)
  ]
}

locals {
  minio_values = {
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      hostname         = "minio.${var.domain}"
      tls              = true
      extraTls = [
        {
          hosts = ["minio.${var.domain}"]
          secretName = "tls-domain"
        }
      ]
    }
  }
}

resource "kubernetes_secret" "minio_domain_tls" {
  count = var.minio_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.minio[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}
