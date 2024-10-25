output "argocd_external_account_bearer_token" {
  value = var.external_argocd_enabled ? data.kubernetes_secret_v1.argocd_external_account[0].data["token"] : ""
}

output "vault_token_reviewer_bearer_token" {
  value = var.vault_token_reviewer_enabled ? data.kubernetes_secret_v1.vault_token_reviewer[0].data["token"] : ""
}

output "vault_provisioner" {
  value = var.vault_provisioner
}