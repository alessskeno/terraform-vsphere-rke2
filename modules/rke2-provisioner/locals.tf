locals {
  master_endpoints_az1 = slice(var.master_ip_range_az1, 0, var.master_node_count)
  master_endpoints_az3 = var.multi_az ? slice(var.master_ip_range_az3, 0, var.master_node_count) : []
  nfs_ip_az1 = try([var.nfs_ip_az1], [])

  worker_endpoints_az1 = slice(var.worker_ip_range_az1, 0, var.worker_node_count)
  worker_endpoints_az3 = var.multi_az ? slice(var.worker_ip_range_az3, 0, var.worker_node_count) : []

  master_endpoints = concat(local.master_endpoints_az1, local.master_endpoints_az3)
  worker_endpoints = concat(local.worker_endpoints_az1, local.worker_endpoints_az3)
  all_endpoints = concat(local.master_endpoints, local.worker_endpoints, local.nfs_ip_az1)
  # included standalone hosts ( except vcs )

  ha_enabled = var.master_node_count > 1 && var.multi_az == false || var.multi_az

  prod_rke2_api_endpoint = var.multi_az ? var.prod_rke2_api_endpoint : var.rke2_api_endpoint

  ova_url = "https://cloud-images.ubuntu.com/${var.ubuntu_variant}/current/${var.ubuntu_variant}-server-cloudimg-amd64.ova"


  harbor_host         = var.env == "prod" ? "127.0.1.1" : var.prod_rke2_api_endpoint
  harbor_domain       = var.env == "prod" ? "harbor.${var.domain}" : "harbor-${var.env}.${var.domain}"
}
