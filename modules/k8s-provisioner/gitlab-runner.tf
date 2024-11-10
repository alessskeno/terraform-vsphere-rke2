# https://docs.gitlab.com/runner/executors/kubernetes.html
# https://docs.gitlab.com/runner/install/kubernetes.html#configuring-gitlab-runner-using-the-helm-chart
# https://docs.gitlab.com/runner/configuration/tls-self-signed.html#supported-options-for-self-signed-certificates-targeting-the-gitlab-server
# https://docs.rke2.io/install/containerd_registry_configuration
# https://github.com/GoogleContainerTools/kaniko/tree/main

resource "kubernetes_namespace" "gitlab_runner" {
  count = var.gitlab_runner_enabled ? 1 : 0
  metadata {
    name   = "gitlab-runner"
    labels = local.default_labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubernetes_limit_range" "gitlab_runner_ns_resource_constraints" {
  count = var.gitlab_runner_enabled ? 1 : 0

  metadata {
    name      = "gitlab-runner-system-limit-range"
    namespace = kubernetes_namespace.gitlab_runner[0].metadata[0].name
    labels    = local.default_labels
  }

  spec {
    limit {
      type = "Container"

      default_request = {
        cpu    = "10m"
        memory = "100Mi"
      }

      default = {
        cpu    = "4"
        memory = "8Gi"
      }

      max = {
        cpu    = "8"
        memory = "8Gi"
      }

      min = {
        cpu    = "1m"
        memory = "1Mi"
      }
    }
  }
}

resource "helm_release" "gitlab_runner" {
  count      = var.gitlab_runner_enabled ? 1 : 0
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace  = kubernetes_namespace.gitlab_runner[0].metadata[0].name
  version    = var.gitlab_runner_version

  set {
    name  = "gitlabUrl"
    value = "https://${local.gitlab_domain}"
  }

  set {
    name  = "concurrent"
    value = 20
  }

  set_sensitive {
    name  = "runnerToken"
    value = var.gitlab_runner_token
  }

  set_sensitive {
    name  = "certsSecretName"
    value = kubernetes_secret.gr_domain_crt[0].metadata[0].name
  }

  values = [
    yamlencode(local.gitlab_runner_values)
  ]
}

locals {
  gitlab_runner_values = {
    runners = {
      config = <<-EOT
        [[runners]]
          [runners.kubernetes]
            namespace = "{{.Release.Namespace}}"
            image = "gcr.io/kaniko-project/executor:debug"
            image_pull_secrets = ["docker-config-harbor"]
            cpu_limit = "1"
            memory_limit = "4Gi"
            cpu_request = "250m"
            memory_request = "1Gi"
          [[runners.kubernetes.volumes.secret]]
            name = "domain-root-crt"
            mount_path = "/etc/gitlab-runner/certs"
            read_only = true
      EOT
    },
    rbac = {
      create            = true,
      clusterWideAccess = false
      rules = [
        {
          apiGroups = [""],
          resources = ["configmaps", "events", "pods", "pods/attach", "pods/exec", "secrets", "services"],
          verbs = ["get", "list", "watch", "create", "patch", "update", "delete"]
        },
        {
          apiGroups = [""],
          resources = ["pods/exec"],
          verbs = ["create", "patch", "delete"]
        },
        {
          apiGroups = [""],
          resources = ["pods/log"],
          verbs = ["get"]
        }
      ]
    }
  }
}

resource "kubernetes_secret" "gr_domain_root_crt" {
  count = var.gitlab_runner_enabled ? 1 : 0
  metadata {
    name      = "domain-root-crt"
    namespace = kubernetes_namespace.gitlab_runner[0].metadata[0].name
  }

  data = {
    "root-ca.crt" = base64decode(var.domain_root_crt)
  }
}

resource "kubernetes_secret" "gr_domain_crt" {
  count = var.gitlab_runner_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.gitlab_runner[0].metadata[0].name
    name      = "domain-crt"
  }

  data = {
    "${local.gitlab_domain}.crt" = base64decode(var.domain_crt)
  }
}

resource "kubernetes_secret" "gr_image_pull_secret_harbor" {
  count = var.gitlab_runner_enabled ? 1 : 0
  metadata {
    name      = "docker-config-harbor"
    namespace = kubernetes_namespace.gitlab_runner[0].metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "harbor.${var.domain}" = {
          username = var.harbor_robot_user
          password = var.general_password
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

/* GUIDE: how to pass secrets/configmaps to gitlab runners by configuring volume types
    https://docs.gitlab.com/runner/executors/kubernetes.html#configure-volume-types

Append similar pattern to gitlab-runner.config.runners.config local:
        [[runners]]
          [runners.kubernetes]
            namespace = "{{.Release.Namespace}}"
            image = "gcr.io/kaniko-project/executor:debug"
            [[runners.kubernetes.host_aliases]]
              ip = "10.0.211.20"
              hostnames = ["harbor.azintelecom.az"]
          [[runners.kubernetes.volumes.secret]]
            name = "${kubernetes_secret.domain_root_crt[0].metadata[0].name}"
            mount_path = "/etc/gitlab-runner/certs"
            read_only = true
          [[runners.kubernetes.volumes.secret]]
            name = "${kubernetes_secret.docker_config_harbor[0].metadata[0].name}"
            mount_path = "/kaniko/.docker"
            read_only = false
            [runners.kubernetes.volumes.secret.items]
              ".dockerconfigjson" = "config.json"

Create respective secret:

resource "kubernetes_secret" "docker_config_harbor" {
  count      = var.gitlab_runner && var.harbor ? 1 : 0
  metadata {
    name = "docker-config-harbor"
    namespace = kubernetes_namespace.gitlab_runner[0].metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "harbor-registry.harbor:5000" = {
          username = var.harbor_robot_user
          password = var.general_password
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
} */
