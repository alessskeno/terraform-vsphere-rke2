## NOTE:  After creating the template virtual machine, we must disable vApp Options in the vSphere Web Client.

resource "vsphere_virtual_machine" "template" {
  count                = var.env == "prod" ? 1 : 0
  depends_on = [data.vsphere_ovf_vm_template.templateLocal]
  name                 = "${var.ubuntu_variant}-server-cloudimg-amd64"
  datacenter_id        = data.vsphere_datacenter.vsphere_datacenter_az1.id
  datastore_id         = data.vsphere_datastore.vsphere_datastore_az1.id
  host_system_id       = data.vsphere_host.vsphere_host_az1.id
  resource_pool_id     = data.vsphere_resource_pool.vsphere_resource_pool_az1.id
  num_cpus             = data.vsphere_ovf_vm_template.templateLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.templateLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.templateLocal.memory
  guest_id             = data.vsphere_ovf_vm_template.templateLocal.guest_id
  firmware             = data.vsphere_ovf_vm_template.templateLocal.firmware
  scsi_type            = data.vsphere_ovf_vm_template.templateLocal.scsi_type


  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.templateLocal.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  sync_time_with_host        = false

  ovf_deploy {
    allow_unverified_ssl_cert = false
    local_ovf_path            = data.vsphere_ovf_vm_template.templateLocal.local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.templateLocal.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.templateLocal.ovf_network_map
  }

  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.root}/files/userdata/template.yml.tpl", {
      hashed_pass  = var.hashed_pass
      vm_gw_ip_az1 = var.vm_gw_ip_az1
    }))
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      "extra_config",
      "num_cores_per_socket",
    ]
  }
}
