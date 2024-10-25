resource "vault_mount" "k8s_secret_mount" {
  path = "k8s-${var.env}"
  type = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "KV v2 secret mount for kubernetes ${var.env} environment"
}
