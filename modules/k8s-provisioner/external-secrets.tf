# https://external-secrets.io/latest/introduction/getting-started/#installing-with-helm
# https://github.com/external-secrets/external-secrets/tree/main/deploy/charts/external-secrets
# https://external-secrets.io/latest/provider/hashicorp-vault/
# https://external-secrets.io/latest/api/clustersecretstore/#example


/*

To manually update secrets from source:
kubectl annotate es my-es force-sync=$(date +%s) --overwrite

Sample externalSecrets resource for tests:


resource "kubectl_manifest" "project_external_secret_test" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "test-external-secret"
      namespace = "external-secrets"
    }
    spec = {
      secretStoreRef = {
        name = "vault-backend-css"
        kind = "ClusterSecretStore"
      }
      refreshInterval = "15s" # can be set to 0 to prevent from being automatically updated
      target = {
        name           = "test-ssm-secret"
        creationPolicy = "Owner"
      }
      data = [{
        secretKey = "testSecretKey.json"
        remoteRef = {
          key = "demo-namespace/demo-project/.vaultkeep"
          property = "test"
        }
        }
      ]
    }
  })
}

*/

resource "kubernetes_namespace" "external_secrets" {
  count = var.external_secrets_enabled ? 1 : 0
  metadata {
    name   = "external-secrets"
    labels = local.default_labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "external_secrets" {

  depends_on = [helm_release.vault]

  count      = var.external_secrets_enabled ? 1 : 0
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.external_secrets_version

  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "webhook.port"
    value = "9443"
  }

  values = [
    yamlencode(local.external_secrets_values)
  ]
}

locals {
  external_secrets_values = {
    affinity = local.az1_affinity_rule
    webhook = {
      affinity = local.az1_affinity_rule
    }
    certController = {
      affinity = local.az1_affinity_rule
    }
  }
}


resource "kubernetes_service_account" "cluster_secret_store" {
  count = var.external_secrets_enabled ? 1 : 0

  metadata {
    name      = "eso-cluster-css-sa"
    namespace = kubernetes_namespace.external_secrets[0].metadata[0].name
  }
}

resource "kubectl_manifest" "cluster_secret_store" {
  count = var.external_secrets_enabled ? 1 : 0

  depends_on = [helm_release.external_secrets]

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "vault-backend-css"
    }
    spec = {
      provider = {
        vault = {
          server  = "https://vault.${var.domain}"
          path = "k8s-${var.env}" # secret-engine ( secret mount )
          version = "v2"
          caProvider = {
            type      = "Secret"
            namespace = "kube-system"
            name      = "domain-root-crt"
            key       = "root-ca.crt"
          }
          auth = {
            kubernetes = {
              mountPath = "k8s-${var.env}"
              role      = "eso-${var.env}-role"
              serviceAccountRef = {
                name      = kubernetes_service_account.cluster_secret_store[0].metadata[0].name
                namespace = kubernetes_namespace.external_secrets[0].metadata[0].name
              }
            }
          }
        }
      }
      conditions = [
        {
          namespaceSelector = {
            matchLabels = {
              "kubernetes.io/environment" = var.env
            }
          }
        }
      ]
    }
  })
}