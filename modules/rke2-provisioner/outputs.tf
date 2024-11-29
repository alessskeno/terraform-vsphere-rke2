output "production_outputs" {
  value = {
    domain              = var.domain
    multi_az            = var.multi_az
    harbor_domain       = local.harbor_domain

    master_node_names = {
      az1 = vsphere_virtual_machine.master_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.master_nodes_az3[*].name : []
    }
    worker_node_names = {
      az1 = vsphere_virtual_machine.worker_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.worker_nodes_az3[*].name : []
    }
    storage_node_count = var.storage_node_count
    worker_node_count  = var.worker_node_count
    master_node_count  = var.master_node_count
    nfs_ip_az1         = var.nfs_ip_az1
  }
}

output "development_outputs" {
  value = {
    domain              = var.domain
    multi_az            = var.multi_az
    harbor_domain       = local.harbor_domain

    master_node_names = {
      az1 = vsphere_virtual_machine.master_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.master_nodes_az3[*].name : []
    }
    worker_node_names = {
      az1 = vsphere_virtual_machine.worker_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.worker_nodes_az3[*].name : []
    }
    storage_node_count = var.storage_node_count
    worker_node_count  = var.worker_node_count
    master_node_count  = var.master_node_count
    nfs_ip_az1         = var.nfs_ip_az1
  }
}

output "staging_outputs" {
  value = {
    domain              = var.domain
    multi_az            = var.multi_az
    harbor_domain       = local.harbor_domain

    master_node_names = {
      az1 = vsphere_virtual_machine.master_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.master_nodes_az3[*].name : []
    }
    worker_node_names = {
      az1 = vsphere_virtual_machine.worker_nodes_az1[*].name
      az3 = var.multi_az ? vsphere_virtual_machine.worker_nodes_az3[*].name : []
    }
    storage_node_count = var.storage_node_count
    worker_node_count  = var.worker_node_count
    master_node_count  = var.master_node_count
    nfs_ip_az1         = var.nfs_ip_az1
  }
}