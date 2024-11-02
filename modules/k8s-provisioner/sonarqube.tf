# https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube
# Note: default credentials are admin:admin

resource "kubernetes_namespace" "sonarqube" {
  count = var.sonarqube_enabled ? 1 : 0
  metadata {
    name = "sonarqube"
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}

resource "helm_release" "sonarqube" {
  count = var.sonarqube_enabled ? 1 : 0

  depends_on = [
    kubernetes_secret.domain_root_crt
  ]

  name       = "sonarqube"
  repository = "https://sonarsource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  namespace  = kubernetes_namespace.sonarqube[0].metadata[0].name
  version    = var.sonarqube_version

  values = [
    yamlencode(local.sonarqube_values)
  ]
}

resource "kubernetes_secret" "sonarqube_domain_root_crt" {
  count = var.sonarqube_enabled ? 1 : 0
  metadata {
    name      = "domain-root-crt"
    namespace = kubernetes_namespace.sonarqube[0].metadata[0].name
  }

  data = {
    "root-ca.crt" = base64decode(var.domain_root_crt)
  }
}

locals {
  sonarqube_values = {
    account = {
      currentAdminPassword = var.general_password
    },
    deploymentStrategy = {
      type = "Recreate"
    },
    affinity = local.az1_affinity_rule
    caCerts = {
      enabled = true
      secret  = "domain-root-crt"
    },
    initSysctl = {
      enabled       = true
      vmMaxMapCount = 524288
      fsFileMax     = 131072
      nofile        = 131072
      nproc         = 8192
      securityContext = {
        privileged = true
      }
    },
    ingress = {
      enabled          = true
      extraLabels      = local.default_labels
      ingressClassName = "nginx"
      annotations = {
        "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        "cert-manager.io/cluster-issuer"                 = kubectl_manifest.cluster_ca_issuer[0].name
        "cert-manager.io/common-name"                    = local.sonarqube_domain
        "cert-manager.io/subject-organization"           = var.domain
      }
      hosts = [
        {
          name     = local.sonarqube_domain
          path     = "/"
          pathType = "Prefix"
        }
      ]
      "tls" = [
        {
          "hosts" = [local.sonarqube_domain]
          "secretName" = "sonarqube-tls"
        }
      ]
    },
    "postgresql" = {
      "enabled" = true
      primary = {
        affinity = local.az1_affinity_rule
      }
    },
    "service" = {
      "type" = "ClusterIP"
    },
    "resources" = {
      "limits" = {
        "cpu"    = "1"
        "memory" = "4Gi"
      }
      "requests" = {
        "cpu"    = "50m"
        "memory" = "2Gi"
      }
    },
    "persistence" = {
      "enabled"      = true
      "storageClass" = var.storage_class_name
      "size"         = "20Gi"
    }
  }
}