resource "kubernetes_service_account" "vault_token_reviewer" {
  count = var.vault_token_reviewer_enabled ? 1 : 0

  metadata {
    name      = "vault-token-reviewer"
    namespace = kubernetes_namespace.vault[0].metadata[0].name
  }
}



resource "kubernetes_cluster_role_binding" "vault_token_reviewer" {
  count = var.vault_token_reviewer_enabled ? 1 : 0

  metadata {
    name = "vault-token-reviewer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_token_reviewer[0].metadata[0].name
    namespace = kubernetes_service_account.vault_token_reviewer[0].metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "vault_token_reviewer_token" {
  count = var.vault_token_reviewer_enabled ? 1 : 0
  metadata {
    name      = "vault-token-reviewer-token"
    namespace = kubernetes_service_account.vault_token_reviewer[0].metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.vault_token_reviewer[0].metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret_v1" "vault_token_reviewer" {
  count = var.vault_token_reviewer_enabled ? 1 : 0
  metadata {
    name      = kubernetes_secret_v1.vault_token_reviewer_token[0].metadata[0].name
    namespace = kubernetes_service_account.vault_token_reviewer[0].metadata[0].namespace
  }
}