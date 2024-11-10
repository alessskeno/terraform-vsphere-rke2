// Doesn't work, maybe in the future it will be needed


/*resource "kubernetes_deployment" "fortigate_exporter" {
  count = var.fortigate_exporter_enabled ? 1 : 0
  metadata {
    name      = "fortigate-exporter"
    namespace = "exporters"
    labels = {
      app = "fortigate-exporter"
    }
  }

  spec {
    replicas = 1 # You can adjust the number of replicas as needed

    selector {
      match_labels = {
        app = "fortigate-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "fortigate-exporter"
        }
      }

      spec {
        volume {
          name = "fortigate-key"
          secret {
            secret_name = kubernetes_secret.fortigate-key[0].metadata[0].name
          }
        }
        container {
          image = "kifeo/fortigate_exporter:latest" # Replace with your image name and tag
          name  = "fortigate-exporter"

          port {
            container_port = 9710
          }
          volume_mount {
            mount_path = "/config"
            name       = "fortigate-key"
          }
          args = ["-auth-file", "/config/fortigate-key.yaml", "-insecure", "-scrape-timeout", "120", "-https-timeout", "30"]
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_fortigate_exporter" {
  count = var.fortigate_exporter_enabled ? 1 : 0
  metadata {
    name      = "fortigate-exporter"
    namespace = "exporters"
  }

  spec {
    selector = {
      app = "fortigate-exporter"
    }

    port {
      port        = 9710
      target_port = 9710
    }
  }
}

resource "kubernetes_secret" "fortigate-key" {
  count = var.fortigate_exporter_enabled ? 1 : 0

  metadata {
    name      = "fortigate-key"
    namespace = "exporters"
  }

  data = {
    "fortigate-key.yaml" = file("${path.cwd}/templates/fortigate_key.yaml")
  }
}
*/