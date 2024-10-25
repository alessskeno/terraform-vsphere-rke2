resource "kubernetes_namespace" "nfs_provisioner" {
  count = var.nfs_provisioner_enabled ? 1 : 0
  metadata {
    name = "nfs-client"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "nfs_subdir_external_provisioner" {
  count      = var.nfs_provisioner_enabled ? 1 : 0
  chart      = "nfs-subdir-external-provisioner"
  name       = "nfs-client"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  namespace  = kubernetes_namespace.nfs_provisioner[0].metadata.0.name
  depends_on = [kubernetes_namespace.nfs_provisioner]

  values = [
    yamlencode(local.nfs_provisioner_values)
  ]

}

locals {
  nfs_provisioner_values = {
    storageClass = {
      defaultClass  = false
      reclaimPolicy = "Retain"
    }
    nfs = {
      server = local.nfs_ip_az1
      path   = "/mnt/nfs_share"
    }
  }
}