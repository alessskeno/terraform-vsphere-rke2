# https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus

/*

Prometheus discovers services to scrape via annotations. You should annotate the NGINX Ingress controller resource,
 for instance in deamonset spec.template.metadata.annotations section should have:

annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "10254"

https://docs.nginx.com/nginx-ingress-controller/logging-and-monitoring/prometheus/

*/

# https://docs.gitlab.com/ee/administration/monitoring/prometheus/   Gitlab Metrics

resource "kubernetes_namespace" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0
  metadata {
    name = "prometheus"
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}

resource "kubernetes_namespace" "exporters" {
  count = var.prometheus_enabled ? 1 : 0
  metadata {
    name = "exporters"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "prometheus" {
  depends_on = [
    helm_release.longhorn,
    kubernetes_secret.prometheus_basic_auth
  ]
  count      = var.prometheus_enabled ? 1 : 0
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.prometheus[0].metadata[0].name

  values = [
    yamlencode(local.prometheus_values)
  ]
}

locals {
  prometheus_values = {
    server = {
      retentionSize = "7GB"
      retention      = "30d"
      persistentVolume = {
        enabled = true
        size    = var.env == "prod" ? "10Gi" : "5Gi"
        storageClass = var.storage_class_name
      }

      ingress = {
        enabled = true
        annotations = {
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
          "nginx.ingress.kubernetes.io/auth-secret"        = "basic-auth"
          "nginx.ingress.kubernetes.io/auth-type"          = "basic"
          "cert-manager.io/cluster-issuer"                 = kubectl_manifest.cluster_ca_issuer[0].name
          "cert-manager.io/common-name"          = local.prometheus_domain
          "cert-manager.io/subject-organization" = var.domain
        }
        hosts = [local.prometheus_domain]
        tls = [
          {
            hosts = [local.prometheus_domain]
            secretName = "prometheus-tls"
          }
        ]
      }
    },
    extraScrapeConfigs = var.env == "prod" ? templatefile("${path.root}/files/configurations/scrape-configs.yaml", {
      bastion_ip = local.nfs_ip_az1
    }) : ""
    serverFiles = {
      "alerting_rules.yml" = yamldecode(templatefile("${path.root}/files/configurations/alerting-rules.yaml", {
        env = title(var.env)
      }))
    },
    alertmanager = {
      enabled = true
      extraSecretMounts = [
        {
          secretName = "slack-template"
          name       = "slack-template"
          mountPath  = "/tmp/"
        }
      ]
      config = {
        global = {
          resolve_timeout = "5m"
        }
        templates = ["/etc/alertmanager/*.tmpl", "/tmp/*.tmpl"]
        route = {
          repeat_interval = "12h"
          group_by = ["alertname"]
          receiver        = "slack-host"
          routes = [
            {
              receiver        = "slack-network"
              group_wait      = "10s"
              matchers = ["type=~junos|mikrotik|cisco"]
              continue        = true
              repeat_interval = "4h"
            },
            {
              receiver        = "slack-host"
              group_wait      = "10s"
              matchers = ["type=~snapshot|vm|kubernetes|host|hpe-ilo|uptimekuma"]
              continue        = true
              repeat_interval = "4h"
            }
          ]
        }
        receivers = [
          {
            name = "slack-network"
            slack_configs = [
              {
                api_url       = var.slack_network_webhook_url
                channel       = var.slack_network_channel_name
                send_resolved = true
                title         = <<-EOT
                    {{ define "__alert_severity_prefix_title" -}}
                        {{ if ne .Status "firing" -}}
                        :white_check_mark:
                        {{- else if eq .CommonLabels.severity "critical" -}}
                        :fire:
                        {{- else if eq .CommonLabels.severity "warning" -}}
                        :warning:
                        {{- else if eq .CommonLabels.severity "info" -}}
                        :information_source:
                        {{- else -}}
                        :question:
                        {{- end }}
                    {{- end }}
                    {{ template "__alert_severity_prefix_title" . }} [{{ .Status | toUpper }}{{ if eq .Status "firing" }} x {{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}
                EOT
                text          = <<-EOT
                  {{ range .Alerts -}}
                  *Severity:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}
                  *Summary:* {{ .Annotations.summary }}
                  *Description:* {{ .Annotations.description }}

                  {{ end }}
                EOT
                actions = [
                  {
                    type = "button"
                    name = "dashboardbutton"
                    text = "Dashboard :grafana:"
                    url  = "https://${local.grafana_domain}/d/{{ .CommonLabels.uid }}"
                  },
                  {
                    type = "button"
                    name = "mutebutton"
                    text = "Silence :no_bell:"
                    url = file("${path.root}/files/configurations/slack-silence-url.txt")
                  }
                ]
              }
            ]
          },
          {
            name = "slack-host"
            slack_configs = [
              {
                api_url       = var.slack_webhook_url
                channel       = var.slack_channel_name
                send_resolved = true
                title         = <<-EOT
                    {{ define "__alert_severity_prefix_title" -}}
                        {{ if ne .Status "firing" -}}
                        :white_check_mark:
                        {{- else if eq .CommonLabels.severity "critical" -}}
                        :fire:
                        {{- else if eq .CommonLabels.severity "warning" -}}
                        :warning:
                        {{- else if eq .CommonLabels.severity "info" -}}
                        :information_source:
                        {{- else -}}
                        :question:
                        {{- end }}
                    {{- end }}
                    {{ template "__alert_severity_prefix_title" . }} [{{ .Status | toUpper }}{{ if eq .Status "firing" }} x {{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}
                EOT
                text          = <<-EOT
                  {{ range .Alerts -}}
                  *Severity:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}
                  *Summary:* {{ .Annotations.summary }}
                  *Description:* {{ .Annotations.description }}

                  {{ end }}
                EOT
                actions = [
                  {
                    type = "button"
                    name = "dashboardbutton"
                    text = "Dashboard :grafana:"
                    url  = "https://${local.grafana_domain}/d/{{ .CommonLabels.uid }}"
                  },
                  {
                    type = "button"
                    name = "mutebutton"
                    text = "Silence :no_bell:"
                    url = file("${path.root}/files/configurations/slack-silence-url.txt")
                  }
                ]
              }
            ]
          }
        ]
      }
      ingress = {
        enabled   = true
        labels    = local.default_labels
        className = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth"
          "nginx.ingress.kubernetes.io/auth-type"   = "basic"
          "cert-manager.io/cluster-issuer"          = kubectl_manifest.cluster_ca_issuer[0].name
        }
        hosts = [
          {
            host = local.alertmanager_domain
            paths = [
              {
                path     = "/"
                pathType = "ImplementationSpecific"
              }
            ]
          }
        ]
        tls = [
          {
            hosts = [local.alertmanager_domain]
            secretName = "alertmanager-tls"
          }
        ]
      }
    }
  }
}


resource "kubernetes_secret" "prometheus_basic_auth" {
  count = var.prometheus_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.prometheus[0].metadata[0].name
    name      = "basic-auth"
  }

  data = {
    auth = var.basic_auth_pass
  }
}

resource "kubernetes_secret" "slack_template" {
  count = var.prometheus_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.prometheus[0].metadata[0].name
    name      = "slack-template"
  }

  data = {
    "slack-templates.tmpl" = file("${path.root}/files/configurations/slack-templates.tmpl")
  }
}
