resource "kubernetes_deployment" "snmp_exporter" {
  depends_on = [kubernetes_config_map.snmp-exporter-configmap-configmap, helm_release.prometheus]
  count      = var.snmp_exporter_enabled ? 1 : 0
  metadata {
    name      = "snmp-exporter"
    namespace = "exporters"
    labels = {
      app = "snmp-exporter"
    }
  }

  spec {
    replicas = 1 # You can adjust the number of replicas as needed

    selector {
      match_labels = {
        app = "snmp-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "snmp-exporter"
        }
      }

      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "snmp-exporter-configmap"
          }
        }
        container {
          image = "prom/snmp-exporter:latest" # Replace with your image name and tag
          name  = "snmp-exporter"

          port {
            container_port = 9116
          }
          volume_mount {
            mount_path = "/etc/snmp_exporter"
            name       = "config-volume"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "snmp_exporter_service" {
  count = var.snmp_exporter_enabled ? 1 : 0
  metadata {
    name      = "snmp-exporter"
    namespace = "exporters"
  }

  spec {
    selector = {
      app = "snmp-exporter"
    }

    port {
      port        = 9116
      target_port = 9116
    }
  }
}

resource "kubernetes_config_map" "snmp-exporter-configmap-configmap" {
  count = var.snmp_exporter_enabled ? 1 : 0

  metadata {
    name      = "snmp-exporter-configmap"
    namespace = "exporters"
  }

  data = {
    "snmp.yml" = file("${path.root}/files/configurations/snmp.yaml")
  }
}