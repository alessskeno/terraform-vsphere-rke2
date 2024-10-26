resource "vsphere_virtual_machine" "master_nodes_az3" {
  depends_on = [vsphere_virtual_machine.master_nodes_az1[0]]
  count                = var.multi_az ? var.master_node_count : 0
  name                 = "${var.env}-az3-master-node-${count.index + 1}"
  datastore_id         = data.vsphere_datastore.vsphere_datastore_az3[0].id
  host_system_id       = data.vsphere_host.vsphere_host_az3[0].id
  resource_pool_id     = data.vsphere_resource_pool.vsphere_resource_pool_az3[0].id
  num_cpus             = var.master_node_cpus
  num_cores_per_socket = var.master_node_cpu_cores
  memory               = var.master_node_memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  firmware             = data.vsphere_virtual_machine.template.firmware
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.vsphere_network_az3[0].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "Hard disk 1"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    size             = var.master_node_disk_size == "" ? data.vsphere_virtual_machine.template.disks.0.size : var.master_node_disk_size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      dns_server_list = var.vm_dns
      linux_options {
        domain    = var.domain
        host_name = "${var.env}-az3-master-node-${count.index + 1}"
        time_zone = "Asia/Baku"
      }
      network_interface {
        ipv4_address = var.master_ip_range_az3[count.index]
        ipv4_netmask = 24
      }

      ipv4_gateway = var.vm_gw_ip_az3
    }
  }
  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.root}/files/userdata/master-node.yml.tpl", {
      master_endpoints_az1 = local.master_endpoints_az1
      master_endpoints_az3 = local.master_endpoints_az3
      worker_endpoints_az1 = local.worker_endpoints_az1
      worker_endpoints_az3 = local.worker_endpoints_az3

      harbor_domain = "harbor.${var.domain}"
      harbor_host   = local.harbor_host
      lb_ip         = var.rke2_api_endpoint
      domain        = var.domain
      env           = var.env
      hashed_pass   = var.hashed_pass
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
}

resource "vsphere_virtual_machine" "worker_nodes_az3" {
  depends_on = [vsphere_virtual_machine.master_nodes_az1[0]]
  count                = var.multi_az ? var.worker_node_count : 0
  name                 = "${var.env}-az3-worker-node-${count.index + 1}"
  datastore_id         = data.vsphere_datastore.vsphere_datastore_az3[0].id
  host_system_id       = data.vsphere_host.vsphere_host_az3[0].id
  resource_pool_id     = data.vsphere_resource_pool.vsphere_resource_pool_az3[0].id
  num_cpus             = var.worker_node_cpus
  num_cores_per_socket = var.worker_node_cpu_cores
  memory               = var.worker_node_memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  firmware             = data.vsphere_virtual_machine.template.firmware
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.vsphere_network_az3[0].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  sync_time_with_host = false

  wait_for_guest_net_timeout = 0

  disk {
    label            = "Hard disk 1"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    size             = var.worker_node_disk_size == "" ? data.vsphere_virtual_machine.template.disks.0.size : var.worker_node_disk_size
  }

  dynamic "disk" {
    for_each = var.lh_storage && count.index < var.storage_node_count ? toset([1]) : []

    content {
      label            = "Hard disk 2"
      unit_number      = 1
      thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
      size             = var.storage_node_disk_size == "" ? data.vsphere_virtual_machine.template.disks.0.size : var.storage_node_disk_size
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      dns_server_list = var.vm_dns
      linux_options {
        domain    = var.domain
        host_name = "${var.env}-az3-worker-node-${count.index + 1}"
        time_zone = "Asia/Baku"
      }
      network_interface {
        ipv4_address = var.worker_ip_range_az3[count.index]
        ipv4_netmask = 24
      }

      ipv4_gateway = var.vm_gw_ip_az3
    }
  }
  extra_config = {
    "guestinfo.userdata" = var.lh_storage && count.index < var.storage_node_count ? base64encode(templatefile("${path.root}/files/userdata/storage-node.yml.tpl", {
        master_endpoints_az1 = local.master_endpoints_az1
        master_endpoints_az3 = local.master_endpoints_az3
        worker_endpoints_az1 = local.worker_endpoints_az1
        worker_endpoints_az3 = local.worker_endpoints_az3

        harbor_domain    = "harbor.${var.domain}"
        harbor_host      = local.harbor_host
        lb_ip            = var.rke2_api_endpoint
        domain           = var.domain
        env              = var.env
        storage_fs_label = var.storage_fs_label
        hashed_pass      = var.hashed_pass
      })) : base64encode(templatefile("${path.root}/files/userdata/worker-node.yml.tpl", {
        master_endpoints_az1 = local.master_endpoints_az1
        master_endpoints_az3 = local.master_endpoints_az3
        worker_endpoints_az1 = local.worker_endpoints_az1
        worker_endpoints_az3 = local.worker_endpoints_az3

        harbor_domain = "harbor.${var.domain}"
        harbor_host   = local.harbor_host
        lb_ip         = var.rke2_api_endpoint
        domain        = var.domain
        env           = var.env
        hashed_pass   = var.hashed_pass
      }))
    "guestinfo.userdata.encoding" = "base64"
  }
  lifecycle {
    ignore_changes = [
      "extra_config"
    ]
    postcondition {
      condition     = (var.lh_storage == true && var.storage_node_count > 0) || (var.lh_storage == false && var.storage_node_count == 0)
      error_message = "Error: If 'lh_storage' is true, then 'storage_node_count' must be greater than 0. If 'lh_storage' is false, then 'storage_node_count' must be 0."
    }
    postcondition {
      condition     = var.worker_node_count >= var.storage_node_count
      error_message = "Error: 'worker_node_count' cannot be less than the value of 'storage_node_count'."
    }
  }
}