variable "domain" {}
variable "domain_root_crt" { default = "" }
variable "domain_root_key" { default = "" }
variable "domain_crt" { default = "" }
variable "domain_key" { default = "" }
variable "env" {}
variable "longhorn_enabled" { default = false }
variable "harbor_enabled" { default = false }
variable "vault_enabled" { default = false }
variable "prometheus_enabled" { default = false }
variable "grafana_enabled" { default = false }
variable "argocd_enabled" { default = false }
variable "external_secrets_enabled" { default = false }
variable "nfs_provisioner_enabled" { default = false }
variable "rabbitmq_enabled" { default = false }
variable "redis_enabled" { default = false }
variable "istio_enabled" { default = false }
variable "gitlab_runner_enabled" { default = false }
variable "loki_enabled" { default = false }
variable "minio_enabled" { default = false }
variable "promtail_enabled" { default = false }
variable "sonarqube_enabled" { default = false }
variable "cert_manager_enabled" { default = false }
variable "external_argocd_enabled" { default = false }
variable "vault_token_reviewer_enabled" { default = false }

variable "longhorn_version" {}
variable "harbor_version" {}
variable "vault_version" {}
variable "prometheus_version" {}
variable "grafana_version" {}
variable "argocd_version" {}
variable "external_secrets_version" {}
variable "nfs_provisioner_version" {}
variable "rabbitmq_version" {}
variable "redis_version" {}
variable "istio_version" {}
variable "gitlab_runner_version" {}
variable "loki_version" {}
variable "minio_version" {}
variable "promtail_version" {}
variable "kiali_version" {}
variable "sonarqube_version" {}
variable "cert_manager_version" {}

variable "gitlab_runner_token" {
  sensitive = true
  default   = ""
}
variable "gitlab_gitops_group_token" {
  sensitive = true
  default   = ""
}
variable "gitops_root_path" { default = "iac/gitops" }
variable "general_user" {
  type      = string
  sensitive = true
}
variable "general_password" {
  sensitive = true
  type      = string
}
variable "harbor_robot_user" {
  sensitive = true
  default   = "robot$ci_user"
}

variable "storage_class_name" {
  default = "longhorn"
}

variable "external_dns_entries" { default = {} }
variable "internal_dns_entries" { default = {} }

variable "harbor_provisioner" { default = false }
variable "vault_provisioner" { default = false }
variable "argocd_provisioner" { default = false }

variable "vcloud_project_outputs" { default = {} }

variable "basic_auth_pass" {
  sensitive = true
  default   = ""
}

variable "vault_root_crt" { default = "" }
variable "vault_crt" { default = "" }
variable "vault_key" { default = "" }

variable "projects" { default = {} }
variable "managed_argocd_environments" { default = {} }
variable "namespaces" { default = {} }

variable "slack_webhook_url" { default = "" }
variable "slack_channel_name" { default = "" }
variable "slack_network_webhook_url" { default = "" }
variable "slack_network_channel_name" { default = "" }