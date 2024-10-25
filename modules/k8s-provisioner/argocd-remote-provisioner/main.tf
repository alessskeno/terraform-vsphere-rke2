resource "kubectl_manifest" "remote_projects" {
  for_each = var.namespaces

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "${each.key}-${var.env}"
      namespace = var.argocd_namespace
      labels    = var.default_labels
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

resource "kubectl_manifest" "remote_project_apps" {
  for_each = var.projects

  depends_on = [kubectl_manifest.remote_projects]


  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "${each.value.name}-${var.env}"
      namespace = var.argocd_namespace
    }
    spec = {
      destination = {
        namespace = each.value.namespace
        server    = var.cluster_name
      }
      project = "${each.value.namespace}-${var.env}"
      source = {
        path           = "."
        repoURL        = "https://${var.gitlab_domain}/${var.gitops_root_path}/${each.value.namespace}/${each.value.name}-manifests.git"
        targetRevision = var.env
      }
      syncPolicy = {
        automated = {}
        syncOptions = [
          "CreateNamespace=false"
        ]
      }
    }
  })
}
