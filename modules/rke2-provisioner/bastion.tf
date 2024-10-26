resource "vsphere_virtual_machine" "bastion_node" {
  depends_on = [vsphere_virtual_machine.template[0]]
  count                = 0
  name                 = "${var.env}-bastion-${count.index + 1}"
  datastore_id         = data.vsphere_datastore.vsphere_datastore_az1.id
  host_system_id       = data.vsphere_host.vsphere_host_az1.id
  resource_pool_id     = data.vsphere_resource_pool.vsphere_resource_pool_az1.id
  num_cpus             = var.master_node_cpus
  num_cores_per_socket = var.master_node_cpu_cores
  memory               = var.master_node_memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  firmware             = data.vsphere_virtual_machine.template.firmware
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.vsphere_network_az1.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  sync_time_with_host = false

  wait_for_guest_net_timeout = 0

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
        host_name = "${var.env}-bastion-${count.index + 1}"
        time_zone = "Asia/Baku"
      }
      network_interface {
        ipv4_address = "10.100.104.3"
        ipv4_netmask = 24
      }
      ipv4_gateway = var.vm_gw_ip_az1
    }
  }
  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.root}/files/userdata/bastion-node.yml.tpl", {
      master_endpoints_az1 = local.master_endpoints_az1
      master_endpoints_az3 = local.master_endpoints_az3
      worker_endpoints_az1 = local.worker_endpoints_az1
      worker_endpoints_az3 = local.worker_endpoints_az3

      lb_ip           = var.rke2_api_endpoint
      domain          = var.domain
      env             = var.env
      hashed_pass     = var.hashed_pass
      rke2_download_kubeconf_path = "${path.root}/files/ansible/kubeconfig"
    }))
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      "extra_config"
    ]
  }
}