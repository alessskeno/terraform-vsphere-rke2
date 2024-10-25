variable "gitlab_domain" {
  default = ""
}

variable "argocd_namespace" {
  default = ""
}

variable "default_labels" {
  default = {}
}

variable "cluster_name" {
  default = ""
}

variable "env" {
  default = ""
}

variable "projects" {
  default = {}
}

variable "gitops_root_path" {
  default = "iac/gitops"
}

variable "namespaces" {
  default = {}
}