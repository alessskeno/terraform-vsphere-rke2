resource "kubernetes_secret" "mktxp_credentials" {
  count      = var.mikrotik_exporter_enabled ? 1 : 0
  depends_on = [helm_release.prometheus]
  metadata {
    name      = "mktxp-credentials"
    namespace = "exporters"
  }
  data = {
    "_mktxp.conf" = <<-EOT
      [MKTXP]
          port = 49090
          socket_timeout = 2

          initial_delay_on_failure = 120
          max_delay_on_failure = 900
          delay_inc_div = 5

          bandwidth = False
          bandwidth_test_interval = 600
          minimal_collect_interval = 5

          verbose_mode = False

          fetch_routers_in_parallel = False
          max_worker_threads = 5
          max_scrape_duration = 10
          total_max_scrape_duration = 30
    EOT
    "mktxp.conf"  = <<-EOT
      [Mikrotik-Router]
          enabled = True
          hostname = 172.18.0.13
          port = 8728
          username = prometheus
          password = "${var.mikrotik_exporter_password}"
          use_ssl = False
          no_ssl_certificate = False
          ssl_certificate_verify = False
          installed_packages = True
          dhcp = False
          dhcp_lease = False
          connections = True
          connection_stats = True
          pool = True
          interface = True
          firewall = True
          ipv6_firewall = False
          ipv6_neighbor = False
          poe = False
          monitor = True
          netwatch = True
          public_ip = True
          route = True
          wireless = False
          wireless_clients = False
          capsman = False
          capsman_clients = False
          kid_control_devices = False
          user = True
          queue = True
          remote_dhcp_entry = null
          use_comments_over_names = True
          check_for_updates = True
    EOT
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "mktxp_exporter" {
  count      = var.mikrotik_exporter_enabled ? 1 : 0
  depends_on = [kubernetes_secret.mktxp_credentials, helm_release.prometheus]
  metadata {
    name      = "mktxp-exporter"
    namespace = "exporters"
    labels = {
      app     = "mktxp-exporter"
      release = "mktxp-exporter"
    }
  }
  spec {
    selector {
      match_labels = {
        app     = "mktxp-exporter"
        release = "mktxp-exporter"
      }
    }
    template {
      metadata {
        labels = {
          app     = "mktxp-exporter"
          release = "mktxp-exporter"
        }
      }
      spec {
        container {
          name  = "mktxp-exporter"
          image = "ghcr.io/akpw/mktxp:latest"
          args  = ["--cfg-dir", "/mktxp_config", "export"]
          resources {
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
          volume_mount {
            name       = "mktxp-credentials"
            mount_path = "/mktxp_config"
          }
          port {
            container_port = 49090
          }
          env {
            name  = "TZ"
            value = "Asia/Baku"
          }
        }
        volume {
          name = "mktxp-credentials"
          secret {
            secret_name = "mktxp-credentials"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mktxp_exporter" {
  count = var.mikrotik_exporter_enabled ? 1 : 0
  metadata {
    name      = "mktxp-exporter"
    namespace = "exporters"
  }
  spec {
    selector = {
      app     = "mktxp-exporter"
      release = "mktxp-exporter"
    }
    port {
      port        = 49090
      target_port = 49090
    }
  }
}