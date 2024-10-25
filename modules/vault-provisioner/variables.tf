variable "vault_authorized_environments" {
  description = "Map of remote environments to configure in Vault"
  type = map(object({
    host                   = string
    reviewer_token         = string
    cluster_ca_certificate = string
  }))

  default = {}
}
variable "env" {
  default = "prod"
}
variable "namespaces" {
  default = {}
}

variable "projects" {
  default = {}
}