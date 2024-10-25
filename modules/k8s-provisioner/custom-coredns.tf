
resource "kubectl_manifest" "patch_coredns_cm" {
  count = local.custom_dns_enabled ? 1 : 0
  yaml_body = templatefile("${path.root}/files/manifests/coredns-local.yaml", {
    external_dns_entries = var.external_dns_entries
    internal_dns_entries = var.internal_dns_entries
  })
}