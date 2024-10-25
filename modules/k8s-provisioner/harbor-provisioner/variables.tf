variable "namespaces" {
  default = {}
}

variable "devops_namespaces" {
  default = {
    iac = ["ci-agent"]
  }
}

variable "general_password" {
  default = ""
}