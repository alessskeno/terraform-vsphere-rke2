resource "kubernetes_namespace" "minio" {
  count = local.prod_env && var.minio_enabled ? 1 : 0
  metadata {
    name   = "minio"
    labels = local.default_labels
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
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
  version = var.minio_version


  values = [
    yamlencode(local.minio_values)
  ]
}

locals {
  minio_values = {
    ingress = {
      annotations = {
        "cert-manager.io/cluster-issuer"       = kubectl_manifest.cluster_ca_issuer[0].name
        "cert-manager.io/common-name"          = local.minio_domain
        "cert-manager.io/subject-organization" = var.domain
      }
      enabled          = true
      ingressClassName = "nginx"
      hostname         = local.minio_domain
      tls              = true
      extraTls = [
        {
          hosts = [local.minio_domain]
          secretName = "minio-tls"
        }
      ]
    }
    persistence = {
      size         = "10Gi"
      storageClass = var.storage_class_name
    }
    mode = "distributed"
    statefulset = {
      replicaCount  = 2
      drivesPerNode = 4
    }
    auth = {
      rootUser     = var.general_user
      rootPassword = var.general_password
    }
  }
}