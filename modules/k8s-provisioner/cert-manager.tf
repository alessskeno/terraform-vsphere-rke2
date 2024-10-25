resource "kubernetes_namespace" "cert_manager" {
  count = var.cert_manager_enabled ? 1 : 0
  metadata {
    name = "cert-manager"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "cert_manager" {
  count = var.cert_manager_enabled ? 1 : 0

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager[0].metadata[0].name
  version    = var.cert_manager_version

  set {
    name  = "webhook.securePort"
    value = "10250"
  }

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "kubernetes_secret" "cert_manager_root_ca" {
  count = var.cert_manager_enabled ? 1 : 0

  metadata {
    name      = "domain-root-crt"
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
  }

  data = {
    "root-ca.crt" = base64decode(var.domain_root_crt)
    "root-ca.key" = base64decode(var.domain_root_key)
  }
}

resource "kubectl_manifest" "cluster_ca_issuer" {
  count = var.cert_manager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cluster-ca-issuer"
    }
    spec = {
      ca = {
        secretName = kubernetes_secret.cert_manager_root_ca[0].metadata[0].name
      }
    }
  })
}