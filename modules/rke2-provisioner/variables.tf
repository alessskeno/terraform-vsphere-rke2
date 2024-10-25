variable "env" {}
variable "multi_az" {}
variable "domain" {
  type    = string
  default = "hostart.az"
}
variable "hashed_pass" {
  type        = string
  description = "Hashed password for the user"
  sensitive   = true
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
variable "vm_gw_ip_az1" {
  type      = string
  sensitive = true
}
variable "vm_gw_ip_az3" {
  type      = string
  sensitive = true
  default   = ""
}
variable "vm_dns" {
  description = "DNS of the virtual machine"
  type = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}
variable "lh_storage" {}
variable "rke2_version" {}
variable "rke2_cni" {}
variable "rke2_token" {
  sensitive = true
}
variable "master_node_count" {}
variable "worker_node_count" {}
variable "storage_node_count" {}

variable "kubevip_range_global" {
  default = ""
}
variable "kubevip_alb_cidr" {}

variable "nfs_enabled" {}

variable "master_ip_range_az1" {}
variable "master_ip_range_az3" {
  default = ""
}
variable "rke2_api_endpoint" {
  default = ""
}
variable "worker_ip_range_az1" {}
variable "worker_ip_range_az3" {
  default = ""
}
variable "prod_rke2_api_endpoint" {
  default = ""
}
variable "nfs_node_cpus" {
  default = 2
  type    = number
}

variable "nfs_node_memory" {
  default = 2048
  type    = number
}

variable "nfs_node_cpu_cores" {
  default = 1
  type    = number
}

variable "nfs_node_disk_size" {
  default = 50
  type    = number
}

variable "nfs_ip_az1" {
  type    = string
  default = ""
}

variable "master_node_cpus" {
  default = 4
  type    = number
}

variable "master_node_memory" {
  default = 8192
  type    = number
}

variable "master_node_cpu_cores" {
  default = 1
  type    = number
}

variable "master_node_disk_size" {
  default = 50
  type    = number
}

variable "worker_node_cpus" {
  default = 4
  type    = number
}

variable "worker_node_memory" {
  default = 8192
  type    = number
}

variable "worker_node_cpu_cores" {
  default = 1
  type    = number
}

variable "worker_node_disk_size" {
  default = 100
  type    = number
}

variable "storage_fs_label" {
  default = "LONGHORN"
}

variable "storage_node_disk_size" {
  default = 150
  type    = number
}

variable "ansible_user" {
  default = "ci-user"
}

variable "ansible_password" {
  sensitive = true
}

variable "update_apt" {
  default = false
  type    = bool
}

variable "install_rke2" {
  default = true
  type    = bool
}

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

variable "ubuntu_variant" {
  default = "jammy"
}