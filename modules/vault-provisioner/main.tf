module "vault-project-resouces" {
  source            = "./vault-project-resources"
  for_each          = local.envs
  env               = each.value
  projects          = var.projects
  namespaces        = var.namespaces
  k8s_auth_backends = vault_auth_backend.kubernetes_auth
}

# Gitlab Runners
data "vault_policy_document" "gitlab_runners" {
  for_each = local.envs
  rule {
    path         = "k8s-${each.key}/data/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "k8s-${each.key}/metadata/*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "gitlab_runners" {
  for_each = local.envs
  name     = "gr-${each.key}-policy"
  policy   = data.vault_policy_document.gitlab_runners[each.key].hcl
}

resource "vault_kubernetes_auth_backend_role" "gitlab_runners" {
  for_each = local.envs
  # Gitlab-runners are active on centralized cluster ( which should be production )
  backend                          = "k8s-${var.env}"
  role_name                        = "gr-role"
  bound_service_account_namespaces = ["gitlab-runner"]
  bound_service_account_names      = ["default"]
  token_policies                   = [for gr-policy in vault_policy.gitlab_runners : gr-policy.name]
}