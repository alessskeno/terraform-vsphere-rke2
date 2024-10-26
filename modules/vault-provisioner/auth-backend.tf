# kubernetes auth method
resource "vault_auth_backend" "kubernetes_auth" {
  for_each    = local.envs
  type        = "kubernetes"
  path        = "k8s-${each.key}"
  description = "Kubernetes auth for ${each.key} cluster"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_auth" {
  for_each             = var.vault_authorized_environments
  backend              = vault_auth_backend.kubernetes_auth[each.key].path
  # The CA certificate and token reviewer JWT are only needed if Vault is authenticating
  # against a different cluster than the one it's running in.
  # Also in that case kubernetes host is set to internal kube-api service instead of external host
  kubernetes_host      = var.env == each.key ? "https://kubernetes.default.svc" : each.value.host
  disable_local_ca_jwt = var.env != each.key
  kubernetes_ca_cert   = var.env == each.key ? null : each.value.cluster_ca_certificate
  token_reviewer_jwt   = var.env == each.key ? null : each.value.reviewer_token
}

resource "vault_mount" "kvv2_secret" {
  path = vault_auth_backend.kubernetes_auth[var.env].path
  type = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "Default secret kv2 mount"
}

resource "vault_kv_secret_v2" "devops_vaultpass_secret_path" {
  mount     = vault_mount.kvv2_secret.path
  name      = "vaultPass/devops/.vaultkeep"
  delete_all_versions = true           # If set to true, permanently deletes all versions for the specified key.
  data_json = jsonencode({}) # "creating empty placeholder secret to generate a namespace and project based path"
  custom_metadata {
    max_versions = 10
    data = {
      "environment" = upper(var.env)
      "owner"       = "Devops"
      "managed-by"  = "Terraform"
    }
  }
}