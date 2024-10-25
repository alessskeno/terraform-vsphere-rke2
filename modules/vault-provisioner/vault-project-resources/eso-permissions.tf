/*

The * wildcard will match any string at the end of a path. The + is used as a wildcard to designate a single directory
within a path. You can find a more verbose explanation and example at
https://developer.hashicorp.com/vault/docs/concepts/policies

* - matches all strings
+ - matches only folders and it does not match across /, + can be used to denote any number of characters bounded within
a single path segment

for a secret located in: "k8s-env/namespace/project/secretname"
Matches:

- "k8s-env/data/*"
- "k8s-env/data/+/*"
- "k8s-env/data/+/+/*"
- "k8s-env/metadata/+/+/*"
*/

# External Secrets Operator
data "vault_policy_document" "external_secrets_operator" {
  rule {
    path         = "${vault_mount.k8s_secret_mount.path}/data/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${vault_mount.k8s_secret_mount.path}/metadata/*"
    capabilities = ["list", "read"]
  }
}

resource "vault_policy" "external_secrets_operator" {
  name   = "eso-${var.env}-policy"
  policy = data.vault_policy_document.external_secrets_operator.hcl
}

resource "vault_kubernetes_auth_backend_role" "external_secrets_operator" {
  backend                          = var.k8s_auth_backends[var.env].path
  role_name                        = "eso-${var.env}-role"
  bound_service_account_namespaces = ["external-secrets"]
  bound_service_account_names      = ["eso-cluster-css-sa"]
  token_policies                   = [vault_policy.external_secrets_operator.name]
}