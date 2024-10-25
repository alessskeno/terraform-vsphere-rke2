resource "kubernetes_secret" "domain_root_crt" {
  metadata {
    name      = "domain-root-crt"
    namespace = "kube-system"
  }

  data = {
    "root-ca.crt" = base64decode(var.domain_root_crt)
  }
}


resource "kubernetes_service" "rke2_ingress_nginx_controller_lb" {
  metadata {
    name      = "rke2-ingress-nginx-controller-lb"
    namespace = "kube-system"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/instance" = "rke2-ingress-nginx"
    }

    port {
      name      = "http"
      port      = 80
      protocol  = "TCP"
      node_port = 30080
    }

    port {
      name      = "https"
      port      = 443
      protocol  = "TCP"
      node_port = 30443
    }

    port {
      name      = "webhook"
      port      = 8443
      protocol  = "TCP"
      node_port = 31243
    }

    external_traffic_policy = "Local"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
      metadata.0.labels,
      spec.0.load_balancer_ip
    ]
  }
}

resource "kubernetes_secret" "ingress_gw_domain_server_crt" {
  count = var.istio_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.istio[0].metadata[0].name
    name      = "domain-server-crt"
    labels    = local.default_labels
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}
