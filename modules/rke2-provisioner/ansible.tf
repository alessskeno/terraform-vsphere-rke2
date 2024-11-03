resource "time_static" "current" {}
resource "null_resource" "ansible_update_apt_packages" {
  count = var.update_apt ? 1 : 0

  provisioner "local-exec" {
    command = "ansible-playbook ${path.root}/files/ansible/update-apt-packages.yml -i '${join(",", local.all_endpoints)}'"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_USER              = var.ansible_user
      ANSIBLE_PASSWORD          = var.ansible_password
    }
  }

  triggers = {
    monthly = time_static.current.month
    nodes = md5(join(",", local.master_endpoints))
  }

  depends_on = [vsphere_virtual_machine.worker_nodes_az1]
}

resource "local_file" "inventory_file" {
  count    = var.install_rke2 ? 1 : 0
  filename = "${path.root}/files/ansible/inventory_${var.env}.ini"
  content = templatefile("${path.root}/files/ansible/inventory_${var.env}.tftpl", {
    env              = var.env,
    master_endpoints_az1 = local.master_endpoints_az1,
    master_endpoints_az3 = local.master_endpoints_az3,
    worker_endpoints_az1 = local.worker_endpoints_az1,
    worker_endpoints_az3 = local.worker_endpoints_az3,
    ansible_user     = var.ansible_user
  })
}

resource "time_sleep" "wait_3_minutes_for_node_ready" {
  count = var.install_rke2 ? 1 : 0
  depends_on = [
    vsphere_virtual_machine.master_nodes_az1, vsphere_virtual_machine.worker_nodes_az1,
    vsphere_virtual_machine.worker_nodes_az3, vsphere_virtual_machine.master_nodes_az3
  ]
  create_duration = "180s"
  triggers = {
    nodes = join(",", concat(local.master_endpoints, local.worker_endpoints))
  }
}

resource "null_resource" "ansible_add_hosts" {
  count = var.install_rke2 ? 1 : 0
  depends_on = [time_sleep.wait_3_minutes_for_node_ready]

  provisioner "local-exec" {
    command = <<EOT
ansible-playbook ${path.root}/files/ansible/add-hosts.yml -i ${join(",", concat(local.master_endpoints, local.worker_endpoints))}
EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_USER              = var.ansible_user
      ANSIBLE_PASSWORD          = var.ansible_password
      MASTER_ENDPOINTS_AZ1 = join(",", local.master_endpoints)
      MASTER_ENDPOINTS_AZ3 = join(",", local.master_endpoints_az3)
      WORKER_ENDPOINTS_AZ1 = join(",", local.worker_endpoints)
      WORKER_ENDPOINTS_AZ3 = join(",", local.worker_endpoints_az3)
      DOMAIN                    = var.domain
      DOMAIN_ROOT_CRT           = var.domain_root_crt
      ENV                       = var.env
      HARBOR_DOMAIN             = local.harbor_domain
    }
  }

  triggers = {
    nodes = join(",", concat(local.master_endpoints, local.worker_endpoints))
    inventory_file = local_file.inventory_file[count.index].filename
  }
}

resource "null_resource" "ansible_install_rke2" {
  depends_on = [null_resource.ansible_add_hosts]
  count = var.install_rke2 ? 1 : 0

  # Then execute the playbook using the generated inventory
  provisioner "local-exec" {
    command = <<EOT
ansible-galaxy role install --force lablabs.rke2 && \
ansible-playbook ${path.root}/files/ansible/install-rke2-playbook.yml -i ${local_file.inventory_file[count.index].filename} --extra-vars "ansible_ssh_pass=${var.ansible_password}" --ssh-extra-args="-o StrictHostKeyChecking=no"
EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_USER              = var.ansible_user
      ANSIBLE_PASSWORD          = var.ansible_password
      RKE2_HA_ENABLED           = local.ha_enabled
      RKE2_KEEPALIVED_ENABLED   = false
      RKE2_KUBEVIP_ENABLED      = true
      KUBEVIP_RANGE_GLOBAL      = var.kubevip_range_global
      KUBEVIP_ALB_CIDR          = var.kubevip_alb_cidr
      RKE2_API_ENDPOINT         = var.rke2_api_endpoint
      RKE2_VERSION              = var.rke2_version
      RKE2_TOKEN                = var.rke2_token
      RKE2_CNI                  = var.rke2_cni
      RKE2_ADDITIONAL_SANS = join(",", [for index in range(0, var.master_node_count) :"${var.env}-az1-master-node-${index + 1}"])
      RKE2_BOOTSTRAP_KUBECONF      = true
      RKE2_BOOTSTRAP_KUBECONF_PATH = "../${path.root}/kubeconfig/"
      RKE2_BOOTSTRAP_KUBECONF_FILE_NAME = "rke2.yaml"
      RKE2_CLUSTER_CIDR            = var.cluster_cidr
      RKE2_SERVICE_CIDR            = var.service_cidr
    }
  }

  triggers = {
    nodes = join(",", concat(local.master_endpoints, local.worker_endpoints))
    playbook_changes = sha256(file("${path.root}/files/ansible/install-rke2-playbook.yml"))
  }
}
