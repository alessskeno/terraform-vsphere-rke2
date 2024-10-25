resource "vault_kv_secret_v2" "project_secret_path" {
  for_each            = var.projects
  mount               = vault_mount.k8s_secret_mount.path
  name                = "${each.value.namespace}/${each.value.name}/.vaultkeep"
  delete_all_versions = true           # If set to true, permanently deletes all versions for the specified key.
  data_json           = jsonencode({}) # "creating empty placeholder secret to generate a namespace and project based path"
  custom_metadata {
    max_versions = 5
    data = {
      "environment" = upper(var.env)
      "owner"       = "Devops"
      "managed-by"  = "Terraform"
    }
  }
}