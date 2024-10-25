variable "remote_argocd_environments" {
  description = "Map of remote environments to configure in ArgoCD"
  type = map(object({
    host                   = string
    bearer_token           = string
    cluster_ca_certificate = string
  }))
  default = {}
}