data "vsphere_datacenter" "vsphere_datacenter_az1" {
  name = var.vsphere_datacenter_az1
}

data "vsphere_datacenter" "vsphere_datacenter_az3" {
  count = var.multi_az ? 1 : 0
  name  = var.vsphere_datacenter_az3
}

data "vsphere_datastore" "vsphere_datastore_az1" {
  name          = var.vsphere_datastore_az1
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az1.id
}

data "vsphere_datastore" "vsphere_datastore_az3" {
  count         = var.multi_az ? 1 : 0
  name          = var.vsphere_datastore_az3
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az3[count.index].id
}

data "vsphere_host" "vsphere_host_az1" {
  name          = var.vsphere_host_az1
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az1.id
}

data "vsphere_host" "vsphere_host_az3" {
  count         = var.multi_az ? 1 : 0
  name          = var.vsphere_host_az3
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az3[count.index].id
}

data "vsphere_resource_pool" "vsphere_resource_pool_az1" {
  name          = var.vsphere_resource_pool_az1
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az1.id
}

data "vsphere_resource_pool" "vsphere_resource_pool_az3" {
  count         = var.multi_az ? 1 : 0
  name          = var.vsphere_resource_pool_az3
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az3[count.index].id
}

data "vsphere_network" "vsphere_network_az1" {
  name          = var.vsphere_network_name_az1
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az1.id
}

data "vsphere_network" "vsphere_network_az3" {
  count         = var.multi_az ? 1 : 0
  name          = var.vsphere_network_name_az3
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az3[count.index].id
}

data "vsphere_virtual_machine" "template" {
  depends_on = [vsphere_virtual_machine.template[0]]
  name          = data.vsphere_ovf_vm_template.template.name
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_az1.id
}

data "vsphere_ovf_vm_template" "template" {
  name              = "${var.ubuntu_variant}-server-cloudimg-amd64"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_host.vsphere_host_az1.resource_pool_id
  datastore_id      = data.vsphere_datastore.vsphere_datastore_az1.id
  host_system_id    = data.vsphere_host.vsphere_host_az1.id
  remote_ovf_url    = local.ova_url
  ovf_network_map = {
    "VM Network" = data.vsphere_network.vsphere_network_az1.id
  }
}

data "vsphere_ovf_vm_template" "templateLocal" {
  name              = "${var.ubuntu_variant}-server-cloudimg-amd64"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_host.vsphere_host_az1.resource_pool_id
  datastore_id      = data.vsphere_datastore.vsphere_datastore_az1.id
  host_system_id    = data.vsphere_host.vsphere_host_az1.id
  local_ovf_path    = "${path.root}/files/ova/${var.ubuntu_variant}-server-cloudimg-amd64.ova"
  ovf_network_map = {
    "VM Network" = data.vsphere_network.vsphere_network_az1.id
  }
}