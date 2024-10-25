# https://github.com/hashicorp/vault-helm
# https://developer.hashicorp.com/vault/docs/platform/k8s/helm
# https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide
# https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide#initialize-and-unseal-vault

/*
 Restart process, init and unseal each one afterwards:
 kubectl scale statefulset vault --replicas=0 -n vault
 kubectl scale statefulset vault --replicas=3 -n vault
 kubectl exec --stdin=true --tty=true vault-0 -- vault operator init
 kubectl exec --stdin=true --tty=true vault-* -- vault operator unseal

 To check active leader endpoint:
 kubectl get endpoints -n vault
 Note: At least 2 active pods in cluster are needed to get a leader, and unlock RAFT storage in HA mode.
*/
resource "kubernetes_namespace" "vault" {
  count = var.vault_enabled || var.vault_token_reviewer_enabled ? 1 : 0
  metadata {
    name = "vault"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

# We are using Opaque type of secrets instead of TLS - not to specify a tls certificate as file during creation
# we are using base64 encoded values and base64 decode function instead.
# We are using the same certificates for listener and RAFT, these can be separate.
resource "kubernetes_secret" "vault_root_crt" {
  count = var.vault_enabled ? 1 : 0
  metadata {
    name      = "tls-ca"
    namespace = kubernetes_namespace.vault[0].metadata[0].name
  }

  data = {
    "ca.crt" = base64decode(var.vault_root_crt)
    # root ca for the raft endpoints to trust - We are using the same for both
    "client-auth-ca.pem" = base64decode(var.vault_root_crt)
    # root ca for the clients to trust - it has to be with pem extension
  }
}

resource "kubernetes_secret" "vault_crt_key_chain" {
  count = var.vault_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.vault[0].metadata[0].name
    name      = "tls-server"
  }

  data = {
    "fullchain.pem" = base64decode(var.vault_crt)
    "server.crt"    = base64decode(var.vault_crt)
    "server.key"    = base64decode(var.vault_key)
  }
}

resource "kubernetes_secret" "vault_domain_tls" {
  count = var.vault_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.vault[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}

resource "helm_release" "vault" {
  depends_on = [
    kubernetes_secret.vault_root_crt,
    kubernetes_secret.vault_crt_key_chain,
    kubernetes_secret.vault_domain_tls
  ]

  count      = var.vault_enabled ? 1 : 0
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault[0].metadata[0].name
  version    = var.vault_version


  set {
    name  = "injector.enabled"
    value = false
  }

  set {
    name  = "server.authDelegator.enabled"
    value = true
  }

  set {
    name  = "server.auditStorage.enabled"
    value = true
  }

  set {
    name  = "server.auditStorage.size"
    value = "2Gi"
  }

  set {
    name  = "server.dataStorage.enabled"
    value = true
  }

  set {
    name  = "server.dataStorage.size"
    value = "10Gi"
  }

  set {
    name  = "server.updateStrategyType"
    value = "RollingUpdate" #  must be 'RollingUpdate' or 'OnDelete'
  }

  values = [
    yamlencode(local.vault_values)
  ]
}

locals {
  vault_values = {
    global = {
      enabled    = true
      tlsDisable = false
    },
    server = {
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name"     = "vault"
                  "app.kubernetes.io/instance" = "vault"
                  "component"                  = "server"
                }
              }
              topologyKey = "topology.kubernetes.io/zone"
            }
          ]
        }
      }
      nodeSelector = {
        "node-role.kubernetes.io/master" = "true"
      }
      tolerations = [
        {
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }
      ]
      ingress = {
        enabled          = true
        labels           = local.default_labels
        ingressClassName = "nginx"
        pathType         = "Prefix"
        activeService    = true
        hosts            = [
          {
            host  = local.vault_domain
            paths = []
          }
        ]
        annotations = {
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          # ensures that all incoming traffic is using SSL/TLS for security
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          # communication between the Ingress controller and the service should be encrypted, vault listener servers on https
          # nginx.ingress.kubernetes.io/proxy-ssl-secret: "namespace/ca-secret"
          # nginx.ingress.kubernetes.io/proxy-ssl-verify: "true"
        }
        tls = [
          {
            hosts      = ["*.${var.domain}"]
            secretName = "tls-domain"
          }
        ]
      }
      resources = {
        requests = {
          memory = "100Mi"
          cpu    = "50m"
        }
        limits = {
          memory = "1Gi"
          cpu    = "500m"
        }
      }
      readinessProbe = {
        enabled = true
        path    = "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204"
      }
      livenessProbe = {
        enabled             = true
        path                = "/v1/sys/health?standbyok=true"
        initialDelaySeconds = 600 # 5 minutes to initialize and unseal all vault server pods
      }
      extraEnvironmentVars = {
        VAULT_CACERT = "/vault/userconfig/tls-ca/ca.crt"
      }
      extraVolumes = [
        # default mount path is "/vault/userconfig/<secretname>/<data-key>"
        { type = "secret", name = "tls-server" }, # domain server crt and key holder secret
        { type = "secret", name = "tls-ca" }      # custom root cert secret
      ]
      standalone = {
        enabled = false
      }
      ha = {
        enabled  = true
        replicas = 3
        raft = {
          enabled   = true
          setNodeId = true
          config    = <<-EOT
            ui = true
            max_lease_ttl = "87600h"
            listener "tcp" {
              address = "[::]:8200"
              cluster_address = "[::]:8201"
              tls_cert_file = "/vault/userconfig/tls-server/fullchain.pem"
              tls_key_file = "/vault/userconfig/tls-server/server.key"
              tls_client_ca_file = "/vault/userconfig/tls-ca/client-auth-ca.pem"
            }
            storage "raft" {
              path = "/vault/data"
              retry_join {
                leader_api_addr = "https://vault-0.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/tls-ca/ca.crt"
                leader_client_cert_file = "/vault/userconfig/tls-server/server.crt"
                leader_client_key_file = "/vault/userconfig/tls-server/server.key"
              }
              retry_join {
                leader_api_addr = "https://vault-1.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/tls-ca/ca.crt"
                leader_client_cert_file = "/vault/userconfig/tls-server/server.crt"
                leader_client_key_file = "/vault/userconfig/tls-server/server.key"
              }
              retry_join {
                leader_api_addr = "https://vault-2.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/tls-ca/ca.crt"
                leader_client_cert_file = "/vault/userconfig/tls-server/server.crt"
                leader_client_key_file = "/vault/userconfig/tls-server/server.key"
              }
            }
            service_registration "kubernetes" {}
          EOT
        }
      }
    },
    ui = {
      enabled         = true
      serviceType     = "ClusterIP"
      serviceNodePort = null
      externalPort    = 8200
    }
  }
}
