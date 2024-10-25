#  https://github.com/grafana/helm-charts/tree/main/charts/promtail

resource "kubernetes_namespace" "promtail" {
  count = var.promtail_enabled ? 1 : 0
  metadata {
    name = "promtail"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "promtail" {
  count = var.promtail_enabled ? 1 : 0

  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = kubernetes_namespace.promtail[0].metadata[0].name
  version    = var.promtail_version

  set {
    name  = "config.clients[0].url"
    value = "http://loki-gateway.loki/loki/api/v1/push"
  }
  values = [
    yamlencode(local.promtail_values)
  ]
}

locals {
  non_log_namespaces = [
    "kube-system",
    "kube-public",
    "kube-node-lease",
    "istio-system",
    "demo-namespace",
    "argocd",
    "external-secrets",
    "longhorn-system",
    "minio",
    "sonarqube",
    "redis",
    "vault",
    "promtail",
    "gitlab-runner",
    "harbor",
    "grafana",
    "default",
    #    "prometheus"
  ]

  non_logs_namespaces = join("|", local.non_log_namespaces)
}

locals {
  promtail_values = {
    #     tolerations = [
    #       {
    #         key      = "node-role.kubernetes.io/armo"
    #         operator = "Exists"
    #         effect   = "NoSchedule"
    #       }
    #     ]
    config = {
      snippets = {
        scrapeConfigs = <<-EOF
          - job_name: kubernetes-pods
            pipeline_stages:
              {{- toYaml .Values.config.snippets.pipelineStages | nindent 4 }}
            kubernetes_sd_configs:
              - role: pod
            relabel_configs:
              - source_labels:
                  - __meta_kubernetes_pod_container_name
                action: drop
                regex: "^(istio-proxy|istio-init)$"
              - source_labels:
                  - __meta_kubernetes_namespace
                action: drop
                regex: "^(${local.non_logs_namespaces})$"
              - source_labels:
                  - __meta_kubernetes_pod_controller_name
                regex: ([0-9a-z-.]+?)(-[0-9a-f]{8,10})?
                action: replace
                target_label: __tmp_controller_name
              - source_labels:
                  - __meta_kubernetes_pod_label_app_kubernetes_io_name
                  - __meta_kubernetes_pod_label_app
                  - __tmp_controller_name
                  - __meta_kubernetes_pod_name
                regex: ^;*([^;]+)(;.*)?$
                action: replace
                target_label: app
              - source_labels:
                  - __meta_kubernetes_pod_label_app_kubernetes_io_instance
                  - __meta_kubernetes_pod_label_instance
                regex: ^;*([^;]+)(;.*)?$
                action: replace
                target_label: instance
              - source_labels:
                  - __meta_kubernetes_pod_label_app_kubernetes_io_component
                  - __meta_kubernetes_pod_label_component
                regex: ^;*([^;]+)(;.*)?$
                action: replace
                target_label: component
              {{- if .Values.config.snippets.addScrapeJobLabel }}
              - replacement: kubernetes-pods
                target_label: scrape_job
              {{- end }}
              {{- toYaml .Values.config.snippets.common | nindent 4 }}
              {{- with .Values.config.snippets.extraRelabelConfigs }}
              {{- toYaml . | nindent 4 }}
              {{- end }}
        EOF
      }
    }
  }
}


