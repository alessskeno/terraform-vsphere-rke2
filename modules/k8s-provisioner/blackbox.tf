# https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter
# https://github.com/prometheus/blackbox_exporter
# https://www.middlewareinventory.com/blog/ssl-expiry-and-uptime-monitor-for-urls-prometheus-blackbox-grafana/


resource "helm_release" "blackbox" {
  count = var.blackbox_exporter_enabled ? 1 : 0

  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  namespace  = "exporters"

  values = [
    yamlencode(local.blackbox_values)
  ]
}

locals {
  blackbox_values = {
    config = {
      modules = {
        http_2xx = {
          prober  = "http"
          timeout = "10s"
          http = {
            valid_http_versions = ["HTTP/1.1", "HTTP/2.0"]
            valid_status_codes  = [] # Defaults to 2xx
            method              = "GET"
            follow_redirects    = true
            preferred_ip_protocol : "ip4"
            fail_if_ssl     = false
            fail_if_not_ssl = false
            tls_config = {
              insecure_skip_verify = true
            }
          }
        }
      }
    }
  }
}