resource "kubernetes_labels" "cp_node_labels" {
  for_each    = local.master_nodes
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.key
  }
  labels = merge({
    "node-role.kubernetes.io/control-plane" = true,
    "node-role.kubernetes.io/etcd"          = true,
    "node-role.kubernetes.io/master"        = true,
    "node.kubernetes.io/instance-type"      = "rke2"
    "topology.kubernetes.io/zone"           = each.value.availability_zone
  }, local.default_labels)
}

resource "kubernetes_labels" "storage_node_labels_az1" {
  count       = local.storage_node_count
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = local.worker_node_names.az1[count.index]
  }
  labels = merge({
    "topology.kubernetes.io/zone"          = "az1",
    "node.longhorn.io/create-default-disk" = true,
    "node-role.kubernetes.io/worker"       = true,
    "node-role.kubernetes.io/storage"      = true
  }, local.default_labels)
}

resource "kubernetes_labels" "storage_node_labels_az3" {
  count       = local.multi_az ? local.storage_node_count : 0
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = local.worker_node_names.az3[count.index]
  }
  labels = merge({
    "topology.kubernetes.io/zone"          = "az3",
    "node.longhorn.io/create-default-disk" = true,
    "node-role.kubernetes.io/worker"       = true,
    "node-role.kubernetes.io/storage"      = true
  }, local.default_labels)
}

resource "kubernetes_labels" "worker_node_labels_az1" {
  count       = local.worker_node_count - local.storage_node_count
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = local.worker_node_names.az1[count.index + local.storage_node_count]
  }
  labels = merge({
    "topology.kubernetes.io/zone"    = "az1"
    "node-role.kubernetes.io/worker" = true
  }, local.default_labels)
}

resource "kubernetes_labels" "worker_node_labels_az3" {
  count       = local.multi_az ? local.worker_node_count - local.storage_node_count : 0
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = local.worker_node_names.az3[count.index + local.storage_node_count]
  }
  labels = merge({
    "topology.kubernetes.io/zone"    = "az3"
    "node-role.kubernetes.io/worker" = true
  }, local.default_labels)
}