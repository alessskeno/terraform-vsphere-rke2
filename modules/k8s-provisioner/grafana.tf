# https://github.com/grafana/helm-charts/tree/main/charts/grafana
# https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/ldap/

resource "kubernetes_namespace" "grafana" {
  count = var.grafana_enabled ? 1 : 0
  metadata {
    name = "grafana"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "grafana" {
  count = var.grafana_enabled ? 1 : 0

  depends_on = [
    kubernetes_secret.grafana_domain_root_crt,
    helm_release.prometheus,
    kubernetes_secret.grafana_domain_tls
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana[0].metadata[0].name
  version    = var.grafana_version

  set {
    name  = "adminUser"
    value = "devops"
  }
  set {
    name  = "deploymentStrategy.type"
    value = "Recreate"
  }

  set_sensitive {
    name  = "adminPassword"
    value = var.general_password
  }

  values = [
    yamlencode(local.grafana_values)
  ]
}

resource "kubernetes_secret" "grafana_domain_root_crt" {
  count = var.grafana_enabled ? 1 : 0

  metadata {
    name      = "domain-root-crt"
    namespace = kubernetes_namespace.grafana[0].metadata[0].name
  }

  data = {
    "root-ca.crt" = base64decode(var.domain_root_crt)
  }
}

resource "kubernetes_secret" "grafana_domain_tls" {
  count = var.grafana_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.grafana[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}

locals {
  grafana_values = {
    affinity = local.az1_affinity_rule
    "grafana.ini" = {
      "auth.ldap" = {
        enabled       = "true"
        allow_sign_up = "true"
        config_file   = "/etc/grafana/ldap.toml"
      }
    }
    persistence = {
      enabled          = true
      size             = "11Gi"
      storageClassName = "longhorn"
      accessModes = [
        "ReadWriteOncePod"
      ]
    }
    podDisruptionBudget = {
      minAvailable   = 0
      maxUnavailable = 1
    }
    extraSecretMounts : [
      {
        name       = "root-ca-crt"
        mountPath  = "/etc/ssl/certs/root-ca.crt"
        secretName = "domain-root-crt"
        readOnly   = true
        subPath    = "root-ca.crt"
      }
    ]
    dashboardProviders = {
      "dashboardproviders.yaml" = {
        apiVersion = 1
        providers = [
          {
            name            = "metrics"
            orgId           = 1
            folder          = "Metrics"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/metrics" # delete from disk to remove provisioned dashboards
            }
          },
          {
            name            = "database-systems"
            orgId           = 1
            folder          = "Database Systems"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/database-systems"
            }
          },
          {
            name            = "logs"
            orgId           = 1
            folder          = "Logs"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/logs"
            }
          },
          {
            name            = "internal-systems"
            orgId           = 1
            folder          = "Internal systems"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/internal-systems"
            }
          },
        ]
      }
    }
    dashboards = {
      database-systems = {
        "postgresql-database-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/postgresql-database-prod-9628.json"
          datasource = "prometheus-prod"
        }
        "postgresql-database-dev" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/postgresql-database-dev-9628.json"
          datasource = "prometheus-dev"
        }
        "postgresql-database-stage" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/postgresql-database-stage-9628.json"
          datasource = "prometheus-stage"
        }
        "mongodb-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/mongodb-prod-12079.json"
          datasource = "prometheus-prod"
        }
        "mongodb-dev" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/mongodb-dev-12079.json"
          datasource = "prometheus-dev"
        }
        "mongodb-stage" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/mongodb-prod-12079.json"
          datasource = "prometheus-stage"
        }
      }
      internal-systems = {
        "blackbox_exporter" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/blackbox_exporter.json"
          datasource = "prometheus-prod"
        }

        "rabbitmq-overview-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/rabbitmq-overview-prod-10991.json"
          datasource = "prometheus-prod"
        }
        "rabbitmq-overview-stage" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/rabbitmq-overview-stage-10991.json"
          datasource = "prometheus-stage"
        }
        "rabbitmq-overview-dev" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/rabbitmq-overview-dev-10991.json"
          datasource = "prometheus-dev"
        }
        "redis-overview-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/redis-prod-763.json"
          datasource = "prometheus-prod"
        }
        "redis-overview-stage" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/redis-stage-763.json"
          datasource = "prometheus-stage"
        }
        "redis-overview-dev" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/redis-dev-763.json"
          datasource = "prometheus-dev"
        }
      }
      metrics = {
        "kubernetes-views-namespaces" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-namespaces-15758.json"
          datasource = "prometheus-${var.env}"
        }
        "kubernetes-persistent-volumes" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-persistent-volumes-13646.json"
          datasource = "prometheus-${var.env}"
        }
        "kubernetes-node-monitoring" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-node-exporter-1860.json?ref_type=heads"
          datasource = "prometheus-${var.env}"
        }
        "kubernetes-ingress-monitoring-v1-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-ingress-prod-9614.json"
          datasource = "prometheus-${var.env}"
        }
        "kubernetes-ingress-monitoring-v2" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-ingress-v2-prod-14314.json"
          datasource = "prometheus-${var.env}"
        }
      }
      logs = {
        "kubernetes-app-logs-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-app-logs-prod-13639.json?ref_type=heads"
          datasource = "loki-prod"
        }
        "kubernetes-container-log-dashboard-prod" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-container-log-dashboard-16966-prod.json"
          datasource = "loki-prod"
        }
        "kubernetes-app-logs-stage" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-app-logs-stage-13639.json?ref_type=heads"
          datasource = "loki-stage"
        }
        "kubernetes-app-logs-dev" = {
          url        = "https://git.azintelecom.az/grafana/dashboards/-/raw/main/logs/kubernetes-app-logs-dev-13639.json?ref_type=heads"
          datasource = "loki-dev"
        }
      }
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      hosts = [
        local.grafana_domain
      ]
      tls = [
        {
          secretName = "tls-domain"
          hosts      = ["*.${var.domain}"]
        }
      ]
    },
    datasources = {
      "datasources.yaml" = {
        apiVersion = 1
        datasources = [
          {
            name      = "prometheus-prod"
            type      = "prometheus"
            url       = "http://prometheus-server.prometheus"
            isDefault = "true"
          },
          {
            name          = "prometheus-stage"
            type          = "prometheus"
            url           = "https://prometheus-stage.azintelecom.az/"
            basicAuth     = true
            basicAuthUser = var.general_user
            secureJsonData = {
              basicAuthPassword = var.general_password
            }
          },
          {
            name          = "prometheus-dev"
            type          = "prometheus"
            url           = "https://prometheus-dev.azintelecom.az/"
            basicAuth     = true
            basicAuthUser = var.general_user
            secureJsonData = {
              basicAuthPassword = var.general_password
            }
          },
          {
            name = "loki-prod"
            type = "loki"
            url  = "http://loki-gateway.loki/"
          },
          {
            name = "loki-stage"
            type = "loki"
            url  = "https://loki-stage.azintelecom.az/"
          },
          {
            name = "loki-dev"
            type = "loki"
            url  = "https://loki-dev.azintelecom.az/"
          }
        ]
      }
    }
  }
}

/*

Note: To enable scrapping for nginx-controller daemonset:

kubectl edit daemonset -n kube-system rke2-ingress-nginx-controller

Edit the daemonset
apiVersion: apps/v1
kind: DaemonSet
metadata:
  ...
spec:
  ...
  template:
    metadata:
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '10254'
    ...

*/