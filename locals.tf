locals {
  vm_gw_ip_az1 = var.vm_gw_ip_az1
  vm_cidr_az1  = var.vm_cidr_az1

  vm_gw_ip_az3 = var.vm_gw_ip_az3
  vm_cidr_az3  = var.vm_cidr_az3

  multi_az = var.multi_az_prod
  kubeconfig_file_path      = "${path.root}/files/ansible/kubeconfig/rke2.yaml"
}