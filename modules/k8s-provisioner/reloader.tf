resource "helm_release" "reloader" {
  count      = var.reloader_enabled ? 1 : 0
  name       = "reloader"
  namespace  = "kube-system"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"

  values = [
    yamlencode(local.reloader_config)
  ]
}
locals {
  reloader_config = {
    reloader = {
      ignoreNamespaces = [
        "kube-system",
        "kube-public",
        "kube-node-lease",
        "default",
        "argocd",
        "external-secrets",
        "externaldns"
      ]
    }
  }
}