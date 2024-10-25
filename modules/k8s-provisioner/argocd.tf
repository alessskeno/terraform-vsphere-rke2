# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
# To get initial default password:
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# The default polling interval is 3 minutes (180 seconds). You can change the setting by updating the timeout.reconciliation
# value in the argocd-cm config map : kubectl edit cm argocd-cm -n argocd
# Argocd notifications:
# https://argocd-notifications.readthedocs.io/en/stable/services/overview/
# https://github.com/argoproj/argo-cd/blob/master/notifications_catalog/install.yaml
# https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/teams/
# https://argocd-notifications.readthedocs.io/en/stable/services/slack/
# Argocd webhook config:
# https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/

resource "kubernetes_namespace" "argocd" {
  count = var.argocd_enabled || var.external_argocd_enabled ? 1 : 0

  metadata {
    name   = "argocd"
    labels = local.default_labels
    annotations = {
      name = "argocd"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

# Helm release
resource "helm_release" "argocd" {
  depends_on = [kubernetes_secret.argocd_domain_tls]
  count      = var.argocd_enabled ? 1 : 0
  name       = "argo"
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version

  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }

  set {
    name  = "configs.cm.timeout\\.reconciliation"
    value = "30s"
  }

  set {
    name  = "notifications.secret.create"
    value = false
  }

  set {
    name  = "notifications.cm.create"
    value = false
  }

  set {
    # password is the general password
    # to generate password: htpasswd -bnBC 10 "" changeme
    # or you can patch the password after deployment:
    # kubectl patch secret -n argocd argocd-secret -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" change | tr -d ':\n')'"}}'
    # if you avoid setting this password you will get argocd-initial-admin-secret which contains initial password value
    # kubectl -n argocd get secret argocd-initial-admin-secret \
    # -o jsonpath="{.data.password}" | base64 -d; echo
    name  = "configs.secret.argocdServerAdminPassword"
    value = "$2y$10$0Vvaww0Zufz6ovTogeBpvuTp4lUnDloUXR72vkqn21WuxWFyJ/C6y"
    #value = "$2y$10$AhJafbLap7hVHMGYQaxMxeW6Dk5jxoTi13C1cq8/bDKr2VliN184a" # i.e THIS ONE IS 'changeme'
  }

  values = [
    yamlencode(local.argocd_values)
  ]
}

locals {
  argocd_values = {
    global = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    },
    controller = {
      resources = {
        limits = {
          cpu    = "2"
          memory = "2048Mi"
        }
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    dex = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    redis = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    redis = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    server = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    repoServer = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    applicationSet = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    notifications = {
      affinity = {
        nodeAffinity = local.az1_affinity_rule.nodeAffinity
      }
    }
    configs = {
      tls = {
        certificates = {
          (local.gitlab_domain) = base64decode(var.domain_root_crt)
        }
      }
    }
  }
}


resource "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.argocd_enabled ? 1 : 0

  depends_on = [
    helm_release.argocd
  ]

  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
    labels    = local.default_labels

    annotations = {}
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = local.argocd_domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argo-argocd-server"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["*.${var.domain}"]
      secret_name = kubernetes_secret.argocd_domain_tls[0].metadata[0].name
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubernetes_secret" "argocd_domain_tls" {
  count = var.argocd_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}


resource "kubernetes_secret" "argocd_private_repo_creds_https" {
  count = var.argocd_enabled ? 1 : 0
  depends_on = [helm_release.argocd]

  metadata {
    name      = "private-repo-creds-https"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    "type"     = "git"
    "url"      = "https://${local.gitlab_domain}/${var.gitops_root_path}"
    "username" = "my-token"
    "password" = var.gitlab_gitops_group_token
  }

  type = "Opaque"
}

# Declarative argocd resources

# LOCAL ARGOCD RESOURCES
resource "kubectl_manifest" "projects" {
  for_each = var.argocd_enabled ? var.namespaces : {}
  depends_on = [helm_release.argocd]

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "${each.key}-${var.env}"
      namespace = kubernetes_namespace.argocd[0].metadata[0].name
      labels    = local.default_labels
    }
    spec = {
      sourceRepos = ["*"]

      destinations = [
        {
          namespace = each.key
          server    = "*"
          name      = "*"
        }
      ]

      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  })
}

resource "kubectl_manifest" "project_apps" {
  for_each = var.argocd_enabled ? var.projects : {}
  depends_on = [helm_release.argocd, kubectl_manifest.projects]

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "${each.value.name}-${var.env}"
      namespace = kubernetes_namespace.argocd[0].metadata[0].name
    }
    spec = {
      destination = {
        namespace = each.value.namespace
        server    = "https://kubernetes.default.svc"
      }
      project = "${each.value.namespace}-${var.env}"
      source = {
        path           = "."
        repoURL        = "https://${local.gitlab_domain}/${var.gitops_root_path}/${each.value.namespace}/${each.value.name}-manifests.git"
        targetRevision = var.env
      }
      # syncPolicy omitted to disable auto-sync on production
    }
  })
}

# REMOTELY MANAGED ARGOCD RESOURCES - EXTERNAL ENVIRONMENTS ( DEV, STAGE)
module "argocd_remote_provisioner" {
  source   = "./argocd-remote-provisioner"
  depends_on = [helm_release.argocd]
  for_each = var.managed_argocd_environments

  cluster_name     = each.value.host
  env              = each.key
  namespaces       = var.namespaces
  projects         = var.projects
  gitlab_domain    = local.gitlab_domain
  gitops_root_path = var.gitops_root_path
  argocd_namespace = kubernetes_namespace.argocd[0].metadata[0].name
  default_labels   = local.default_labels
}