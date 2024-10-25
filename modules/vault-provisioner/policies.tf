# Admin policy
# vault token create -policy="admin-policy" -ttl="87600h" -display-name="administrator" -format=json | jq -r '.auth.client_token'
data "vault_policy_document" "admin_policy" {

  rule {
    path         = "*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
}

resource "vault_policy" "admin_policy" {
  name   = "admin-policy"
  policy = data.vault_policy_document.admin_policy.hcl
}