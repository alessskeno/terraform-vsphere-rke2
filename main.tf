# Pre-requisites: python3.x, ansible, ansible-core, sshpass, whois(mkpasswd)

# Production Cluster
module "vault_provisioner" {
  # depends_on = [module.k8s_provisioner_prod]
  count      = module.k8s_provisioner_prod.vault_provisioner ? 1 : 0
  source     = "./modules/vault-provisioner"
  env        = "prod"
  namespaces = local.namespaces
  projects   = local.projects
  vault_authorized_environments = {
    # dev = {
    #   host                   = cidrhost(var.vm_cidr_az1, 210)
    #   reviewer_token         = module.k8s_provisioner_dev.vault_token_reviewer_bearer_token
    #   cluster_ca_certificate = base64decode(var.cluster_ca_cert_dev)
    # },
    #     stage = {
    #       host           = cidrhost(var.vm_cidr_az1, 110)
    #       reviewer_token = module.k8s_provisioner_stage.vault_token_reviewer_bearer_token
    #       cluster_ca_certificate = base64decode(var.cluster_ca_cert_stage)
    #     },
    prod = {
      host = cidrhost(var.vm_cidr_az1, 10)
      reviewer_token = module.k8s_provisioner_prod.vault_token_reviewer_bearer_token
      cluster_ca_certificate = base64decode(var.cluster_ca_cert_prod)
    }
  }
}

# module "argocd_provisioner" {
#   source = "./modules/argocd-provisioner"
#   # depends_on = [module.k8s_provisioner_prod]
#   count      = module.k8s_provisioner_prod.argocd_provisioner ? 1 : 0
#   remote_argocd_environments = {
#     # dev = {
#     #   host                   = cidrhost(var.vm_cidr_az1, 210)
#     #   bearer_token           = module.k8s_provisioner_dev.argocd_external_account_bearer_token
#     #   cluster_ca_certificate = base64decode(var.cluster_ca_cert_dev)
#     # }
#     #     stage = {
#     #       host         = cidrhost(var.vm_cidr_az1, 110)
#     #       bearer_token = module.k8s_provisioner_stage.argocd_external_account_bearer_token
#     #       cluster_ca_certificate = base64decode(var.cluster_ca_cert_stage)
#     #     }
#   }
#
#   providers = {
#     argocd = argocd.prod
#   }
# }

module "k8s_provisioner_prod" {
  depends_on = [module.rke2_prod_cluster]
  source = "./modules/k8s-provisioner"
  domain = var.domain
  env    = "prod"

  vcloud_project_outputs = module.rke2_prod_cluster.production_outputs

  gitlab_gitops_group_token  = var.gitlab_gitops_group_token
  gitlab_runner_token        = var.gitlab_runner_token
  general_password           = var.general_password
  general_user               = var.general_user
  basic_auth_pass            = var.basic_auth_pass
  juniper_exporter_password  = var.juniper_exporter_password
  mikrotik_exporter_password = var.mikrotik_exporter_password
  vsphere_user               = var.username
  vsphere_password           = var.password
  vsphere_server             = var.vsphere_server

  slack_channel_name         = var.slack_channel_name
  slack_webhook_url          = var.slack_webhook_url
  slack_network_channel_name = var.slack_network_channel_name
  slack_network_webhook_url  = var.slack_network_webhook_url

  vault_crt      = var.vault_crt
  vault_key      = var.vault_key
  vault_root_crt = var.vault_root_crt

  domain_root_crt = var.domain_root_crt
  domain_crt      = var.domain_crt
  domain_key      = var.domain_key
  domain_root_key = var.domain_root_key



  external_secrets_version = "0.10.4"
  gitlab_runner_version    = "0.69.0"
  grafana_version          = "8.5.2"
  harbor_version           = "1.15.1"
  istio_version            = "1.23.2"
  loki_version             = "6.16.0"
  longhorn_version         = "1.7.2"
  minio_version            = "14.7.15"
  nfs_provisioner_version  = "4.0.18"
  prometheus_version       = "25.28.0"
  promtail_version         = "6.16.6"
  rabbitmq_version         = "15.0.2"
  redis_version            = "20.2.0"
  vault_version            = "0.28.1"
  kiali_version            = "1.89.0"
  sonarqube_version        = "10.7.0+3598"
  argocd_version           = "7.7.1"
  cert_manager_version     = "1.16.1"

  external_secrets_enabled = false
  gitlab_runner_enabled    = false
  grafana_enabled          = true
  harbor_enabled           = false
  istio_enabled            = true
  loki_enabled             = false
  longhorn_enabled         = true
  minio_enabled            = false
  nfs_provisioner_enabled  = false
  reloader_enabled         = false

  prometheus_enabled         = true
  fortigate_exporter_enabled = false
  juniper_exporter_enabled   = true
  mikrotik_exporter_enabled  = true
  snmp_exporter_enabled      = true
  vmware_exporter_enabled    = true
  blackbox_exporter_enabled  = true

  promtail_enabled             = false
  rabbitmq_enabled             = false
  redis_enabled                = false
  vault_enabled                = true
  vault_token_reviewer_enabled = true
  vault_provisioner            = true
  sonarqube_enabled            = false
  argocd_enabled               = true
  cert_manager_enabled         = true
  external_argocd_enabled      = false

  providers = {
    harbor     = harbor.prod
    helm       = helm.prod
    kubernetes = kubernetes.prod
    kubectl    = kubectl.prod
  }

  internal_dns_entries = {
    "harbor.${var.domain}"     = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "argocd.${var.domain}"     = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "vault.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "sonar.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "grafana.${var.domain}"    = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "kiali.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "prometheus.${var.domain}" = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "loki.${var.domain}"       = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "minio.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "rabbitmq.${var.domain}"   = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "redis.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
    "istio.${var.domain}"      = "nginx-ingress-controller.kube-system.svc.cluster.local"
  }

  external_dns_entries = {
    "vcsa.hostart.local" = "10.100.70.250"
  }

  projects           = local.projects
  namespaces         = local.namespaces
  storage_class_name = "longhorn"

  # managed_argocd_environments = module.argocd_provisioner.remote_argocd_environments
}


module "rke2_prod_cluster" {
  source       = "./modules/rke2-provisioner"
  env          = "prod"
  domain       = var.domain
  multi_az     = true
  install_rke2 = true
  lh_storage   = true
  hashed_pass  = var.hashed_pass
  cluster_cidr = var.cluster_cidr
  service_cidr = var.service_cidr
  nfs_enabled  = false
  update_apt   = false
  rke2_token   = var.rke2_token
  rke2_version = "v1.30.5+rke2r1"
  rke2_cni     = "canal"

  ansible_password  = var.ansible_password
  domain_crt        = var.domain_crt
  domain_key        = var.domain_key
  domain_root_crt   = var.domain_root_crt
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
  master_ip_range_az1       = [for i in range(61, 69) : cidrhost(local.vm_cidr_az1, i)]
  worker_ip_range_az1       = [for i in range(71, 79) : cidrhost(local.vm_cidr_az1, i)]
  kubevip_range_global = join("-", [cidrhost(var.vm_cidr_az1, 50)], [cidrhost(var.vm_cidr_az1, 60)])
  kubevip_alb_cidr          = "${cidrhost(var.vm_cidr_az1, 20)}/32"
  rke2_api_endpoint = cidrhost(var.vm_cidr_az1, 10)
  vsphere_datacenter_az1    = var.vsphere_datacenter_az1
  vsphere_host_az1          = var.vsphere_host_az1
  vsphere_resource_pool_az1 = var.vsphere_resource_pool_az1
  vsphere_datastore_az1     = var.vsphere_datastore_az1
  vsphere_network_name_az1  = var.vsphere_network_name_az1
  vm_gw_ip_az1              = local.vm_gw_ip_az1
  nfs_ip_az1 = cidrhost(local.vm_cidr_az1, 70)

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

# module "k8s_provisioner_stage" {
#   source = "./modules/k8s-provisioner"
#   domain = var.domain
#   env    = "stage"
#
#   vcloud_project_outputs = module.rke2_stage_cluster.production_outputs
#
#   gitlab_gitops_group_token = var.gitlab_gitops_group_token
#   gitlab_runner_token       = var.gitlab_runner_token
#   gitlab_user               = var.gitlab_user
#   general_password          = var.general_password
#   general_user              = var.general_user
#   basic_auth_pass           = var.basic_auth_pass
#
#   slack_channel_name         = var.slack_channel_name
#   slack_webhook_url          = var.slack_webhook_url
#   slack_network_channel_name = var.slack_network_channel_name
#   slack_network_webhook_url  = var.slack_network_webhook_url
#
#   vault_crt      = var.vault_crt
#   vault_key      = var.vault_key
#   vault_root_crt = var.vault_root_crt
#
#   domain_root_crt = var.domain_root_crt
#   domain_crt      = var.domain_crt
#   domain_key      = var.domain_key
#
#
#
#   external_secrets_version = "0.10.4"
#   gitlab_runner_version    = "0.69.0"
#   grafana_version          = "8.5.2"
#   harbor_version           = "1.15.1"
#   istio_version            = "1.23.2"
#   loki_version             = "6.16.0"
#   longhorn_version         = "1.7.2"
#   minio_version            = "14.7.15"
#   nfs_provisioner_version  = "4.0.18"
#   prometheus_version       = "25.28.0"
#   promtail_version         = "6.16.6"
#   rabbitmq_version         = "15.0.2"
#   redis_version            = "20.2.0"
#   vault_version            = "0.28.1"
#   kiali_version            = "1.89.0"
#   sonarqube_version        = "10.7.0+3598"
#   argocd_version           = "7.7.1"
#
#   external_secrets_enabled     = true
#   gitlab_runner_enabled        = false
#   grafana_enabled              = false
#   harbor_enabled               = false
#   istio_enabled                = true
#   loki_enabled                 = false
#   longhorn_enabled             = true
#   minio_enabled                = false
#   nfs_provisioner_enabled      = false
#   prometheus_enabled           = false
#   promtail_enabled             = false
#   rabbitmq_enabled             = true
#   redis_enabled                = true
#   vault_enabled                = false
#   kiali_enabled                = false
#   sonarqube_enabled            = false
#   argocd_enabled               = false
#   vault_token_reviewer_enabled = true
#   external_argocd_enabled      = true
#
#   providers = {
#     helm       = helm.stage
#     kubernetes = kubernetes.stage
#     kubectl    = kubectl.stage
#   }
#
#   internal_dns_entries = {}
#
#   external_dns_entries = {
#     "vcsa.hostart.local" = "10.100.70.250"
#   }
#
#   projects   = local.projects
#   namespaces = local.namespaces
#   storage_class_name = "longhorn"
#
#   managed_argocd_environments = {}
# }

# module "rke2_staging_cluster" {
#   source                   = "./modules/rke2-provisioner"
#   env                      = "stage"
#   domain                   = var.domain
#   multi_az                 = false
#   install_rke2             = true
#   lh_storage               = true
#   hashed_pass              = var.hashed_pass
#   cluster_cidr             = var.cluster_cidr
#   service_cidr             = var.service_cidr
#   nfs_enabled              = true
#   update_apt               = false
#   rke2_token               = var.rke2_token
#   rke2_version             = "v1.30.5+rke2r1"
#   rke2_cni                 = "canal"
#   kubevip_range_global     = join("-", [cidrhost(var.vm_cidr_az1, 140)], [cidrhost(var.vm_cidr_az1, 150)])
#   kubevip_cidr_kube_system = "${cidrhost(var.vm_cidr_az1, 120)}/32"
#   rke2_api_endpoint        = cidrhost(var.vm_cidr_az1, 110)
#
#   ansible_password  = var.ansible_password
#   domain_crt        = var.domain_crt
#   domain_key        = var.domain_key
#   domain_root_crt   = var.domain_root_crt
#   master_node_count = var.master_node_count_staging
#   worker_node_count = var.worker_node_count_staging
#   storage_node_count = var.storage_node_count_staging
#
#   # Resources
#   worker_node_cpus      = 1
#   worker_node_memory    = 1024
#   worker_node_disk_size = 30
#
#   master_node_cpus      = 1
#   master_node_memory    = 1024
#   master_node_disk_size = 30
#
#   storage_node_disk_size = 50
#
#   nfs_node_disk_size = 200
#
#   # AZ1
#   master_ip_range_az1      = [for i in range(11, 19) : cidrhost(local.vm_cidr_az1, i)]
#   worker_ip_range_az1      = [for i in range(21, 29) : cidrhost(local.vm_cidr_az1, i)]
#   vsphere_datacenter_az1   = var.vsphere_datacenter_az1
#   vsphere_host_az1         = var.vsphere_host_az1
#   vsphere_datastore_az1    = var.vsphere_datastore_az1
#   vsphere_network_name_az1 = var.vsphere_network_name_az1
#   vm_gw_ip_az1             = local.vm_gw_ip_az1
#   nfs_ip_az1               = cidrhost(local.vm_cidr_az1, 30)
#
# }

# Development Cluster
# module "k8s_provisioner_dev" {
#   source = "./modules/k8s-provisioner"
#   domain = var.domain
#   env    = "dev"
#
#   vcloud_project_outputs = module.rke2_dev_cluster.production_outputs
#
#   gitlab_gitops_group_token = var.gitlab_gitops_group_token
#   gitlab_runner_token       = var.gitlab_runner_token
#   general_password          = var.general_password
#   general_user              = var.general_user
#   basic_auth_pass           = var.basic_auth_pass
#
#   slack_channel_name         = var.slack_channel_name
#   slack_webhook_url          = var.slack_webhook_url
#   slack_network_channel_name = var.slack_network_channel_name
#   slack_network_webhook_url  = var.slack_network_webhook_url
#
#   vault_crt      = var.vault_crt
#   vault_key      = var.vault_key
#   vault_root_crt = var.vault_root_crt
#
#   domain_root_crt = var.domain_root_crt
#   domain_crt      = var.domain_crt
#   domain_key      = var.domain_key
#
#
#
#   external_secrets_version = "0.10.4"
#   gitlab_runner_version    = "0.69.0"
#   grafana_version          = "8.5.2"
#   harbor_version           = "1.15.1"
#   istio_version            = "1.23.2"
#   loki_version             = "6.16.0"
#   longhorn_version         = "1.7.2"
#   minio_version            = "14.7.15"
#   nfs_provisioner_version  = "4.0.18"
#   prometheus_version       = "25.28.0"
#   promtail_version         = "6.16.6"
#   rabbitmq_version         = "15.0.2"
#   redis_version            = "20.2.0"
#   vault_version            = "0.28.1"
#   kiali_version            = "1.89.0"
#   sonarqube_version        = "10.7.0+3598"
#   argocd_version           = "7.7.1"
#   cert_manager_version     = "1.16.1"
#
#
#   external_secrets_enabled     = true
#   gitlab_runner_enabled        = false
#   grafana_enabled              = false
#   harbor_enabled               = false
#   istio_enabled                = true
#   loki_enabled                 = false
#   longhorn_enabled             = true
#   minio_enabled                = false
#   nfs_provisioner_enabled      = false
#   prometheus_enabled           = false
#   promtail_enabled             = false
#   rabbitmq_enabled             = true
#   redis_enabled                = true
#   vault_enabled                = false
#   kiali_enabled                = false
#   sonarqube_enabled            = false
#   argocd_enabled               = false
#   cert_manager_enabled         = false
#   vault_token_reviewer_enabled = true
#   external_argocd_enabled      = true
#
#   providers = {
#     helm       = helm.dev
#     kubernetes = kubernetes.dev
#     kubectl    = kubectl.dev
#   }
#
#   internal_dns_entries = {}
#
#   external_dns_entries = {
#     "vcsa.hostart.local" = "10.100.70.250"
#   }
#
#   projects   = local.projects
#   namespaces = local.namespaces
#   storage_class_name = "longhorn"
#
#   managed_argocd_environments = {}
# }

# module "rke2_dev_cluster" {
#   source               = "./modules/rke2-provisioner"
#   env                  = "dev"
#   domain               = var.domain
#   multi_az             = false
#   install_rke2         = false
#   lh_storage           = true
#   hashed_pass          = var.hashed_pass
#   cluster_cidr         = var.cluster_cidr
#   service_cidr         = var.service_cidr
#   nfs_enabled          = false
#   update_apt           = false
#   rke2_token           = var.rke2_token
#   rke2_version         = "v1.30.5+rke2r1"
#   rke2_cni             = "canal"
#   kubevip_range_global = join("-", [cidrhost(var.vm_cidr_az1, 230)], [cidrhost(var.vm_cidr_az1, 240)])
#   kubevip_alb_cidr     = "${cidrhost(var.vm_cidr_az1, 220)}/32"
#   rke2_api_endpoint    = cidrhost(var.vm_cidr_az1, 210)
#
#   ansible_password  = var.ansible_password
#   domain_crt        = var.domain_crt
#   domain_key        = var.domain_key
#   domain_root_crt   = var.domain_root_crt
#   master_node_count = var.master_node_count_dev
#   worker_node_count = var.worker_node_count_dev
#   storage_node_count = var.storage_node_count_dev
#
#   # Resources
#   worker_node_cpus      = 4
#   worker_node_memory    = 4096
#   worker_node_disk_size = 60
#
#   master_node_cpus      = 2
#   master_node_memory    = 2048
#   master_node_disk_size = 50
#
#   storage_node_disk_size = 50
#
#   nfs_node_disk_size = 50
#
#   # AZ1
#   master_ip_range_az1      = [for i in range(211, 219) : cidrhost(local.vm_cidr_az1, i)]
#   worker_ip_range_az1      = [for i in range(221, 229) : cidrhost(local.vm_cidr_az1, i)]
#   vsphere_datacenter_az1   = var.vsphere_datacenter_az1
#   vsphere_host_az1         = var.vsphere_host_az1
#   vsphere_datastore_az1    = var.vsphere_datastore_az1
#   vsphere_network_name_az1 = var.vsphere_network_name_az1
#   vm_gw_ip_az1             = local.vm_gw_ip_az1
# }
