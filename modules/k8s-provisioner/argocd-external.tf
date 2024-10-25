resource "kubernetes_service_account" "argocd_external_account" {
  count = var.external_argocd_enabled ? 1 : 0

  metadata {
    name      = "argocd-external-account"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "argocd_external_account" {
  count = var.external_argocd_enabled ? 1 : 0

  metadata {
    name = "argocd-external-account-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.argocd_external_account[0].metadata[0].name
    namespace = kubernetes_service_account.argocd_external_account[0].metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "argocd_external_account_token" {
  count = var.external_argocd_enabled ? 1 : 0
  metadata {
    name      = "argocd-external-account-token"
    namespace = kubernetes_service_account.argocd_external_account[0].metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.argocd_external_account[0].metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret_v1" "argocd_external_account" {
  count = var.external_argocd_enabled ? 1 : 0
  metadata {
    name      = kubernetes_secret_v1.argocd_external_account_token[0].metadata[0].name
    namespace = kubernetes_service_account.argocd_external_account[0].metadata[0].namespace
  }
}