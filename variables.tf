#===========================#
# VMware vCenter connection #
#===========================#

variable "username" {
  type        = string
  description = "VMware vSphere username"
  sensitive   = true
  default     = ""
}

variable "password" {
  type        = string
  description = "VMware vSphere password"
  sensitive   = true
  default     = ""
}

variable "hashed_pass" {
  type        = string
  description = "Hashed password for the user"
  sensitive   = true
}

variable "vsphere_server" {
  type      = string
  sensitive = true
  default   = ""
}


variable "vsphere_datacenter_az1" {
  type      = string
  sensitive = true
}

variable "vsphere_datacenter_az3" {
  type      = string
  sensitive = true
  default   = ""
}


variable "vsphere_host_az1" {
  type      = string
  sensitive = true
}

variable "vsphere_resource_pool_az1" {
  type      = string
  sensitive = true
}

variable "vsphere_resource_pool_az3" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vsphere_host_az3" {
  type      = string
  sensitive = true
  default   = ""
}


variable "vsphere_datastore_az1" {
  type      = string
  sensitive = true
}

variable "vsphere_datastore_az3" {
  type      = string
  sensitive = true
  default   = ""
}


variable "vsphere_network_name_az1" {
  type      = string
  sensitive = true
}

variable "vsphere_network_name_az3" {
  type      = string
  sensitive = true
  default   = ""
}


#================================#
# VMware vSphere virtual machine #
#================================#

variable "domain" {
  type    = string
  default = "hostart.az"
}

variable "domain_crt" {
  type      = string
  sensitive = true
}

variable "domain_key" {
  type      = string
  sensitive = true
}

variable "domain_root_crt" {
  type      = string
  sensitive = true
}

variable "domain_root_key" {
  type      = string
  sensitive = true
}

variable "rke2_token" {
  sensitive = true
}

variable "ansible_password" {
  sensitive = true
}

variable "general_password" {
  type      = string
  sensitive = true
}

variable "general_user" {
  type      = string
  sensitive = true
}

variable "multi_az_prod" {
  type    = bool
  default = false
}

# Production vars
variable "storage_node_count_prod" {
  default = 1
}

variable "worker_node_count_prod" {
  default = 2
}

variable "master_node_count_prod" {
  default = 1
}

# Staging vars
variable "storage_node_count_staging" {
  default = 1
}

variable "worker_node_count_staging" {
  default = 1
}

variable "master_node_count_staging" {
  default = 1
}

# Development vars
variable "storage_node_count_dev" {
  default = 0
}

variable "worker_node_count_dev" {
  default = 0
}

variable "master_node_count_dev" {
  default = 0
}

#=======================================#
# VMware vSphere network configuration #
#=======================================#

variable "cluster_cidr" {
  type        = string
  description = "Kubernetes cluster CIDR"
  default     = "10.253.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR"
  default     = "10.254.0.0/16"
}

variable "vm_gw_ip_az1" {
  type      = string
  sensitive = true
}

variable "vm_cidr_az1" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vm_gw_ip_az3" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vm_cidr_az3" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vm_dns" {
  description = "DNS of the virtual machine"
  type = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}

# PRODUCTION AUTH VARS

# variable "kube_api_endpoint_prod" {
#   type      = string
#   sensitive = true
# }
#
# variable "client_certificate_prod" {
#   type      = string
#   sensitive = true
# }
#
# variable "client_key_prod" {
#   type      = string
#   sensitive = true
# }
#
# variable "cluster_ca_cert_prod" {
#   type      = string
#   sensitive = true
# }

variable "gitlab_gitops_group_token" {
  type      = string
  sensitive = true
}

variable "gitlab_runner_token" {
  type      = string
  sensitive = true
}

variable "basic_auth_pass" {
  type      = string
  sensitive = true
}

# STAGING AUTH VARS

# variable "kube_api_endpoint_stage" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "client_certificate_stage" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "client_key_stage" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "cluster_ca_cert_stage" {
#   type      = string
#   sensitive = true
#   default   = ""
# }

# DEVELOPMENT AUTH VARS

# variable "kube_api_endpoint_dev" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "client_certificate_dev" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "client_key_dev" {
#   type      = string
#   sensitive = true
#   default   = ""
# }
#
# variable "cluster_ca_cert_dev" {
#   type      = string
#   sensitive = true
#   default   = ""
# }

# SLACK CREDENTIALS
variable "slack_channel_name" {
  default = ""
}

variable "slack_webhook_url" {
  default = ""
}

variable "slack_network_channel_name" {
  default = ""
}

variable "slack_network_webhook_url" {
  default = ""
}

# VAULT CREDENTIALS
variable "vault_admin_token" {
  default   = ""
  sensitive = true
}

variable "vault_crt" {
  description = "Vault certificate in base64 format"
  default     = ""
}

variable "vault_key" {
  description = "Vault server key in base64 format"
  default     = ""
}

variable "vault_root_crt" {
  description = "Vault Root certificate in base64 format"
  default     = ""
}