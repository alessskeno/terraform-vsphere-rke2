resource "kubernetes_namespace" "project_namespace" {
  for_each = var.namespaces
  metadata {
    name   = each.key
    labels = local.default_labels
    annotations = {
      name = each.key
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubernetes_limit_range" "project_ns_resource_constraints" {
  for_each = var.namespaces

  metadata {
    name      = "${each.key}-limit-range"
    namespace = kubernetes_namespace.project_namespace[each.key].metadata[0].name
    labels    = local.default_labels
  }

  spec {
    limit {
      type = "Container"

      default_request = {
        cpu    = "10m"
        memory = "50Mi"
      }

      default = {
        cpu    = "50m"
        memory = "250Mi"
      }

      max = {
        cpu    = "2"
        memory = "2Gi"
      }

      min = {
        cpu    = "1m"
        memory = "1Mi"
      }
    }
  }
}