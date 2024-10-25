resource "argocd_cluster" "remote_clusters" {
  for_each = var.remote_argocd_environments
  server   = each.value.host
  config {
    bearer_token = each.value.bearer_token
    tls_client_config {
      ca_data = each.value.cluster_ca_certificate
    }
  }
}
