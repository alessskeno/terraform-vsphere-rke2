# https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube
# Note: default credentials are admin:admin

resource "kubernetes_namespace" "sonarqube" {
  count = var.sonarqube_enabled ? 1 : 0
  metadata {
    name = "sonarqube"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "sonarqube" {
  count = var.sonarqube_enabled ? 1 : 0

  depends_on = [
    kubernetes_secret.sonarqube_domain_tls,
    kubernetes_secret.domain_root_crt
  ]

  name       = "sonarqube"
  repository = "https://sonarsource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  namespace  = kubernetes_namespace.sonarqube[0].metadata[0].name
  version    = var.sonarqube_version

  set_sensitive {
    name  = "account.currentAdminPassword"
    value = var.general_password
  }

  set {
    name  = "deploymentStrategy.type"
    value = "Recreate"
  }

  values = [
    yamlencode(local.sonarqube_values)
  ]
}

resource "kubernetes_secret" "sonarqube_domain_tls" {
  count = var.sonarqube_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.sonarqube[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
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
          "hosts"      = ["*.${var.domain}"]
          "secretName" = "tls-domain"
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
      "storageClass" = "longhorn"
      "size"         = "20Gi"
    }
  }
}