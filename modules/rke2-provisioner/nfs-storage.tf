resource "vsphere_virtual_machine" "nfs_storage" {
  depends_on = [vsphere_virtual_machine.template]
  count                = var.env == "prod" && var.nfs_enabled ? 1 : 0
  name                 = "${var.env}-az1-nfs-node"
  datastore_id         = data.vsphere_datastore.vsphere_datastore_az1.id
  host_system_id       = data.vsphere_host.vsphere_host_az1.id
  resource_pool_id     = data.vsphere_resource_pool.vsphere_resource_pool_az1.id
  num_cpus             = var.nfs_node_cpus
  num_cores_per_socket = var.nfs_node_cpu_cores
  memory               = var.nfs_node_memory
  guest_id             = data.vsphere_virtual_machine.template[count.index].guest_id
  firmware             = data.vsphere_virtual_machine.template[count.index].firmware
  scsi_type            = data.vsphere_virtual_machine.template[count.index].scsi_type

  network_interface {
    network_id   = data.vsphere_network.vsphere_network_az1.id
    adapter_type = data.vsphere_virtual_machine.template[count.index].network_interface_types[0]
  }
  sync_time_with_host = false

  wait_for_guest_net_timeout = 0

  disk {
    label            = "Hard disk 1"
    thin_provisioned = data.vsphere_virtual_machine.template[count.index].disks.0.thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template[count.index].disks.0.eagerly_scrub
    size             = var.nfs_node_disk_size == "" ? data.vsphere_virtual_machine.template[count.index].disks.0.size : var.nfs_node_disk_size
  }

  clone {

    template_uuid = data.vsphere_virtual_machine.template[count.index].id

    customize {
      dns_server_list = var.vm_dns
      linux_options {
        domain    = var.domain
        host_name = "${var.env}-nfs-storage-${count.index + 1}"
        time_zone = "Asia/Baku"
      }
      network_interface {
        ipv4_address = var.nfs_ip_az1
        ipv4_netmask = 24
      }
      ipv4_gateway = var.vm_gw_ip_az1
    }
  }

  # vapp {
  #   properties = {
  #     "guestinfo.userdata" = base64encode(templatefile("${path.root}/files/userdata/nfs-storage.yml.tpl", {
  #       hashed_pass = var.hashed_pass
  #     }))
  #     "guestinfo.hostname"  = "${var.env}-az1-nfs-node"
  #     "guestinfo.ipaddress" = var.nfs_ip_az1
  #     "guestinfo.netmask"   = "255.255.255.0"
  #     "guestinfo.gateway"   = var.vm_gw_ip_az1
  #     "guestinfo.ssh"       = "True"
  #   }
  # }

  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.root}/files/userdata/nfs-storage.yml.tpl", {
      hashed_pass = var.hashed_pass

    }))
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      vapp.0.properties,
    ]
  }
}
