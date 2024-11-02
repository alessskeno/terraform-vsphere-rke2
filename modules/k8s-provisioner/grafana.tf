# https://github.com/grafana/helm-charts/tree/main/charts/grafana
# https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/ldap/

resource "kubernetes_namespace" "grafana" {
  count = var.grafana_enabled ? 1 : 0
  metadata {
    name = "grafana"
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}

resource "helm_release" "grafana" {
  count = var.grafana_enabled ? 1 : 0

  depends_on = [
    helm_release.longhorn,
    kubernetes_secret.grafana_domain_root_crt
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana[0].metadata[0].name
  version    = var.grafana_version

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

locals {
  grafana_values = {
    adminUser     = var.general_user
    adminPassword = var.general_password
    deploymentStrategy = {
      type = "Recreate"
    }
    affinity = local.az1_affinity_rule
    persistence = {
      enabled          = true
      size             = "11Gi"
      storageClassName = var.storage_class_name
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
            name            = "internal-systems"
            orgId           = 1
            folder          = "Internal Systems"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/internal-systems"
            }
          },
          {
            name            = "vmware-vsphere"
            orgId           = 1
            folder          = "VMware-vSphere"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/vmware-vsphere"
            }
          },
          {
            name            = "logs"
            orgId           = 1
            folder          = "Kubernetes App Logs"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/logs"
            }
          },
          {
            name            = "network-devices"
            orgId           = 1
            folder          = "Network Devices"
            type            = "file"
            disableDeletion = true
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/network-devices"
            }
          }
        ]
      }
    }
    dashboards = {
      internal-systems = {
        uptimekuma-exporter = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/uptimekuma-exporter.json"
          datasource = "prometheus"
        },
        discord-exporter = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/discord-monitoring.json"
          datasource = "prometheus"
        },
      },
      vmware-vsphere = {
        vmware-vsphere-cluster = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/vmware-cluster.json"
          datasource = "prometheus"
        },
        vmware-vsphere-esx = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/vmware-esx-host-information.json"
          datasource = "prometheus"
        },
        vmware-vsphere-esxi = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/vmware-esxi-import.json"
          datasource = "prometheus"
        },
        vmware-vsphere-overview = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/vmware-overview.json"
          datasource = "prometheus"
        },
        vmware-vsphere-vm = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/vmware-vm.json"
          datasource = "prometheus"
        }
      },
      logs = {
        kubernetes-app-logs = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/kubernetes-app-logs.json"
          datasource = "loki"
        }
      },
      network-devices = {
        pathnet = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/pathnet-monitoring.json"
          datasource = "prometheus"
        },
        mikrotik-routeros = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/mikrotik-monitoring.json"
          datasource = "prometheus"
        },
        fortigate-routeros = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/fortigate-monitoring.json"
          datasource = "prometheus"
        },
        cisco-network-devices = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/snmp-stats.json"
          datasource = "prometheus"
        },
        juniper-network-devices = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/juniper-monitoring.json"
          datasource = "prometheus"
        },
        hpe-ilo-devices = {
          url        = "https://gitlab.hostart.az/grafana/dashboards/-/raw/main/logs/snmp-ilo.json"
          datasource = "prometheus"
        }
      }
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      annotations = {
        "cert-manager.io/cluster-issuer"       = kubectl_manifest.cluster_ca_issuer[0].name
        "cert-manager.io/common-name"          = local.grafana_domain
        "cert-manager.io/subject-organization" = var.domain
      }
      hosts = [
        local.grafana_domain
      ]
      tls = [
        {
          secretName = "grafana-tls"
          hosts = [local.grafana_domain]
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
            url           = "https://prometheus-stage.${var.domain}/"
            basicAuth     = true
            basicAuthUser = var.general_user
            secureJsonData = {
              basicAuthPassword = var.general_password
            }
          },
          {
            name          = "prometheus-dev"
            type          = "prometheus"
            url           = "https://prometheus-dev.${var.domain}/"
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
            url  = "https://loki-stage.${var.domain}/"
          },
          {
            name = "loki-dev"
            type = "loki"
            url  = "https://loki-dev.${var.domain}/"
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