# Pre-requisites: python3.x, ansible, ansible-core, sshpass, whois(mkpasswd)

# Production Cluster
module "rke2_prod_cluster" {
  source       = "./modules/rke2-provisioner"
  env          = "prod" # Environment name
  domain       = var.domain # Domain name
  multi_az     = true # If you want to create multi-az cluster
  install_rke2 = true # Install RKE2
  lh_storage   = true # Local storage for worker nodes
  hashed_pass  = var.hashed_pass # Hashed password for user creation
  cluster_cidr = var.cluster_cidr # Kubernetes cluster CIDR
  service_cidr = var.service_cidr # Kubernetes service CIDR
  nfs_enabled  = false # Change to true if you want to enable nfs server
  update_apt   = false # Update apt packages by changing to true
  rke2_token   = var.rke2_token
  rke2_version = "v1.30.5+rke2r1"
  rke2_cni     = "canal" # Alternatives: flannel, calico, cilium
  kubevip_range_global = join("-", [cidrhost(var.vm_cidr_az1, 50)], [cidrhost(var.vm_cidr_az1, 60)]) # Global IP range for LoadBalancer IPs
  kubevip_alb_cidr          = "${cidrhost(var.vm_cidr_az1, 20)}/32" # IP for Nginx Ingress Controller Service
  rke2_api_endpoint = cidrhost(var.vm_cidr_az1, 10) # API Server IP

  ansible_password  = var.ansible_password # Ansible user password
  domain_crt        = var.domain_crt # Domain certificate
  domain_key        = var.domain_key # Domain key
  domain_root_crt   = var.domain_root_crt # Root certificate
  master_node_count = var.master_node_count_prod
  worker_node_count = var.worker_node_count_prod
  storage_node_count = var.storage_node_count_prod

  # Resources
  worker_node_cpus      = 8
  worker_node_memory    = 8192
  worker_node_disk_size = 100

  master_node_cpus      = 8
  master_node_memory    = 8192
  master_node_disk_size = 50

  storage_node_disk_size = 100

  nfs_node_disk_size = 50

  # AZ1
  master_ip_range_az1       = [for i in range(61, 69) : cidrhost(local.vm_cidr_az1, i)] # Master node IP range
  worker_ip_range_az1       = [for i in range(71, 79) : cidrhost(local.vm_cidr_az1, i)] # Worker node IP range
  vsphere_datacenter_az1    = var.vsphere_datacenter_az1 # vSphere datacenter name
  vsphere_host_az1          = var.vsphere_host_az1 # vSphere host name
  vsphere_resource_pool_az1 = var.vsphere_resource_pool_az1 # vSphere resource pool name
  vsphere_datastore_az1     = var.vsphere_datastore_az1 # vSphere datastore name
  vsphere_network_name_az1  = var.vsphere_network_name_az1 # vSphere network name
  vm_gw_ip_az1              = local.vm_gw_ip_az1 # Gateway IP
  nfs_ip_az1 = cidrhost(local.vm_cidr_az1, 70) # NFS server IP

  # AZ3
  master_ip_range_az3       = [for i in range(81, 89) : cidrhost(local.vm_cidr_az3, i)]
  worker_ip_range_az3       = [for i in range(91, 99) : cidrhost(local.vm_cidr_az3, i)]
  vsphere_datacenter_az3    = var.vsphere_datacenter_az3
  vsphere_host_az3          = var.vsphere_host_az3
  vsphere_resource_pool_az3 = var.vsphere_resource_pool_az3
  vsphere_datastore_az3     = var.vsphere_datastore_az3
  vsphere_network_name_az3  = var.vsphere_network_name_az3
  vm_gw_ip_az3              = local.vm_gw_ip_az3
}

# Staging Cluster
/*module "rke2_staging_cluster" {
  source                   = "./modules/rke2-provisioner"
  env                      = "stage"
  domain                   = var.domain
  multi_az                 = false
  install_rke2             = true
  lh_storage               = true
  hashed_pass              = var.hashed_pass
  cluster_cidr             = var.cluster_cidr
  service_cidr             = var.service_cidr
  nfs_enabled              = true
  update_apt               = false
  rke2_token               = var.rke2_token
  rke2_version             = "v1.30.5+rke2r1"
  rke2_cni                 = "canal"
  kubevip_range_global     = join("-", [cidrhost(var.vm_cidr_az1, 140)], [cidrhost(var.vm_cidr_az1, 150)])
  kubevip_alb_cidr = "${cidrhost(var.vm_cidr_az1, 120)}/32"
  rke2_api_endpoint        = cidrhost(var.vm_cidr_az1, 110)

  ansible_password  = var.ansible_password
  domain_crt        = var.domain_crt
  domain_key        = var.domain_key
  domain_root_crt   = var.domain_root_crt
  master_node_count = var.master_node_count_staging
  worker_node_count = var.worker_node_count_staging
  storage_node_count = var.storage_node_count_staging

  # Resources
  worker_node_cpus      = 1
  worker_node_memory    = 1024
  worker_node_disk_size = 30

  master_node_cpus      = 1
  master_node_memory    = 1024
  master_node_disk_size = 30

  storage_node_disk_size = 50

  nfs_node_disk_size = 200

  # AZ1
  master_ip_range_az1      = [for i in range(11, 19) : cidrhost(local.vm_cidr_az1, i)]
  worker_ip_range_az1      = [for i in range(21, 29) : cidrhost(local.vm_cidr_az1, i)]
  vsphere_datacenter_az1   = var.vsphere_datacenter_az1
  vsphere_host_az1         = var.vsphere_host_az1
  vsphere_resource_pool_az1 = var.vsphere_resource_pool_az1
  vsphere_datastore_az1    = var.vsphere_datastore_az1
  vsphere_network_name_az1 = var.vsphere_network_name_az1
  vm_gw_ip_az1             = local.vm_gw_ip_az1
  nfs_ip_az1               = cidrhost(local.vm_cidr_az1, 30)

}*/

# Development Cluster
/*module "rke2_dev_cluster" {
  source               = "./modules/rke2-provisioner"
  env                  = "dev"
  domain               = var.domain
  multi_az             = false
  install_rke2         = false
  lh_storage           = true
  hashed_pass          = var.hashed_pass
  cluster_cidr         = var.cluster_cidr
  service_cidr         = var.service_cidr
  nfs_enabled          = false
  update_apt           = false
  rke2_token           = var.rke2_token
  rke2_version         = "v1.30.5+rke2r1"
  rke2_cni             = "canal"
  kubevip_range_global = join("-", [cidrhost(var.vm_cidr_az1, 230)], [cidrhost(var.vm_cidr_az1, 240)])
  kubevip_alb_cidr     = "${cidrhost(var.vm_cidr_az1, 220)}/32"
  rke2_api_endpoint    = cidrhost(var.vm_cidr_az1, 210)

  ansible_password  = var.ansible_password
  domain_crt        = var.domain_crt
  domain_key        = var.domain_key
  domain_root_crt   = var.domain_root_crt
  master_node_count = var.master_node_count_dev
  worker_node_count = var.worker_node_count_dev
  storage_node_count = var.storage_node_count_dev

  # Resources
  worker_node_cpus      = 4
  worker_node_memory    = 4096
  worker_node_disk_size = 60

  master_node_cpus      = 2
  master_node_memory    = 2048
  master_node_disk_size = 50

  storage_node_disk_size = 50

  nfs_node_disk_size = 50

  # AZ1
  master_ip_range_az1      = [for i in range(211, 219) : cidrhost(local.vm_cidr_az1, i)]
  worker_ip_range_az1      = [for i in range(221, 229) : cidrhost(local.vm_cidr_az1, i)]
  vsphere_datacenter_az1   = var.vsphere_datacenter_az1
  vsphere_host_az1         = var.vsphere_host_az1
  vsphere_resource_pool_az1 = var.vsphere_resource_pool_az1
  vsphere_datastore_az1    = var.vsphere_datastore_az1
  vsphere_network_name_az1 = var.vsphere_network_name_az1
  vm_gw_ip_az1             = local.vm_gw_ip_az1
}*/
