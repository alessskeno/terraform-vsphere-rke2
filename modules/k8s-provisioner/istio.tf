# https://istio.io/latest/docs/setup/install/helm/
# https://artifacthub.io/packages/helm/istio-official/base
# https://artifacthub.io/packages/helm/istio-official/istiod
# https://artifacthub.io/packages/helm/istio-official/gateway
# https://github.com/istio/istio/tree/master/manifests/charts/base
# https://github.com/istio/istio/tree/master/manifests/charts/istio-control/istio-discovery
# https://github.com/istio/istio/tree/master/manifests/charts/gateway
# https://istio.io/latest/docs/reference/config/networking/
# https://istio.io/latest/docs/tasks/security/authentication/authn-policy/
# https://istio.io/latest/docs/reference/config/security/authorization-policy/
# https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/
# https://istio.io/latest/docs/tasks/traffic-management/egress/egress-gateway/
# https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/
# https://istio.io/latest/docs/tasks/traffic-management/egress/egress-control/#envoy-passthrough-to-external-services
# https://istio.io/latest/docs/tasks/observability/logs/access-log/
# https://istio.io/latest/docs/ops/configuration/traffic-management/dns-proxy/
# https://istio.io/latest/docs/reference/config/networking/service-entry/


# https://kiali.io/docs/installation/installation-guide/install-with-helm/
# https://github.com/kiali/helm-charts
# https://artifacthub.io/packages/helm/kiali/kiali-server
# https://kiali.io/docs/faq/authentication/
# https://kiali.io/docs/configuration/authentication/
# https://kiali.io/docs/configuration/kialis.kiali.io/


# https://artifacthub.io/packages/helm/jaegertracing/jaeger
# https://github.com/jaegertracing/helm-charts

/*

In Istio, determining which pods have a sidecar proxy is typically managed through the use of Istio's automatic sidecar
injection. Here's how you can control it:

    Namespace-Level Control: You can enable or disable automatic sidecar injection at the namespace level by labeling
    the namespace with istio-injection=enabled or istio-injection=disabled. When enabled, all pods deployed to that
    namespace will automatically have the Istio sidecar injected.

    Pod-Level Control: If you need more granular control, you can use annotations on individual pod specifications. By
    adding the annotation sidecar.istio.io/inject: "true" or sidecar.istio.io/inject: "false" to a pod's metadata, you
    can override the namespace-level setting for that specific pod.

Create Service Entries: If your pod needs to access specific external services, create ServiceEntry resources to allow
access to those services:

    apiVersion: networking.istio.io/v1alpha3
    kind: ServiceEntry
    metadata:
      name: allow-external-service
    spec:
      hosts:
      - "external.service.com"
      ports:
      - number: 80
        name: http
        protocol: HTTP
      resolution: DNS

    apiVersion: networking.istio.io/v1alpha3
    kind: ServiceEntry
    metadata:
      name: allowed-external-service
    spec:
      hosts:
      - "example.com"
      location: MESH_EXTERNAL
      ports:
      - number: 443
        name: https
        protocol: HTTPS
      resolution: DNS


 If you have databases or other external services that do not have DNS names, you can use Istio's ServiceEntry to
 define custom DNS names for these services within your Istio-enabled environment. This approach allows your
 workloads with Istio sidecar proxies to refer to these services by user-defined, logical DNS names instead of IP
 addresses:

    apiVersion: networking.istio.io/v1alpha3
    kind: ServiceEntry
    metadata:
      name: postgres-external-service
    spec:
      hosts:
      - "db.example.com"
      location: MESH_EXTERNAL
      ports:
      - number: 5432
        name: tcp-postgres
        protocol: TCP
      resolution: STATIC
      endpoints:
      - address: "192.0.2.10"

Create AuthorizationPolicy to allow internal access:

    apiVersion: security.istio.io/v1beta1
    kind: AuthorizationPolicy
    metadata:
      name: allow-pod-a-to-pod-b
      namespace: your-namespace
    spec:
      selector:
        matchLabels:
          app: pod-b
      rules:
      - from:
        - source:
            principals: ["cluster.local/ns/your-namespace/sa/service-account-of-pod-a"]

    apiVersion: security.istio.io/v1beta1
    kind: AuthorizationPolicy
    metadata:
      name: egress-access-control
      namespace: istio-system
    spec:
      action: ALLOW
      rules:
      - to:
        - operation:
            hosts:
            - "example.com"
      when:
      - key: source.labels["app"]
        values: ["allowed-app"]


 Example egress configuration:

    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: istio-egressgateway
      namespace: istio-system
    spec:
      selector:
        istio: egressgateway
      servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
        - "example.com"

    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: route-external
      namespace: istio-system
    spec:
      hosts:
      - "example.com"
      gateways:
      - istio-egressgateway
      http:
      - match:
        - gateways:
          - istio-egressgateway
        route:
        - destination:
            host: example.com
            port:
              number: 80

  To observe sidecar proxy logs:
   kubectl logs -l app=demo-project -c istio-proxy -f

*/

// To resolve the issue of "Another operation is in progress (rollback/upgrade/restore) on instance "istio-system""

resource "kubernetes_namespace" "istio" {
  count = var.istio_enabled ? 1 : 0
  metadata {
    name = "istio-system"
    labels = merge(local.default_labels, {
      k8s-balancer = "true"
    })
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

# Istio base CRDs
resource "helm_release" "istio_base" {
  count = var.istio_enabled ? 1 : 0

  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.istio_version
}

# Istio Operator - istioD
resource "helm_release" "istiod" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istio_base]

  name       = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.istio_version

  values = [
    yamlencode(local.istiod_values)
  ]
}

locals {
  istiod_values = {
    profile = "ambient"
    pilot = {
      env = {
        "VERIFY_CERTIFICATE_AT_CLIENT"     = "true"
        "ENABLE_AUTO_SNI"                  = "true"
        "PILOT_ENABLE_HBONE"               = "true"
        "CA_TRUSTED_NODE_ACCOUNTS"         = "istio-system/ztunnel,kube-system/ztunnel"
        "PILOT_ENABLE_AMBIENT_CONTROLLERS" = "true"
      }
      autoscaleMin = local.prod_env ? 2 : 1
      topologySpreadConstraints = [
        {
          maxSkew           = 1
          topologyKey       = "topology.kubernetes.io/zone"
          whenUnsatisfiable = "ScheduleAnyway"
          labelSelector = {
            matchLabels = {
              app = "istiod"
            }
          }
        }
      ]
    }
    meshConfig = {
      defaultConfig = {
        proxyMetadata = {
          ISTIO_META_DNS_CAPTURE  = "true"
          ISTIO_META_ENABLE_HBONE = "true"
        }
      }
      accessLogFile         = "/dev/stdout"
      accessLogEncoding = "TEXT" # | JSON
      accessLogFormat       = "[%START_TIME%] \"%REQ(:METHOD)%\" \"%REQ(USER-AGENT)%\" \"%REQ(:AUTHORITY)%\" \"%UPSTREAM_HOST%\" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% \"%REQ(X-FORWARDED-FOR)%\" \"%REQ(X-REQUEST-ID)%\" \"%REQ(:PATH)%\" \"%REQ(USER-AGENT)%\" \"%REQ(X-ENVOY-ORIGINAL-PATH)%\"\n"
      enablePrometheusMerge = var.prometheus_enabled
      outboundTrafficPolicy = {
        mode = "ALLOW_ANY" # | REGISTRY_ONLY
      }
    }
  }
}

# Istio CNI
resource "helm_release" "istio_cni" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istiod]

  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.istio_version

  values = [
    yamlencode(local.istio_cni_values)
  ]
}

locals {
  istio_cni_values = {
    profile = "ambient"
    logLevel = "error" # |trace|debug|info|warning|error|critical|off|
    privileged = true
    ambient = {
      enabled = true
    }
  }
}

# Istio Ingress Gateway
resource "helm_release" "istio_ingress_gateway" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istiod]

  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.istio_version

  values = [
    yamlencode(local.istio_ingress_gateway_values)
  ]
}

locals {
  istio_ingress_gateway_values = {
    kind = "DaemonSet"
    #    autoscaling = {
    #      minReplicas = local.prod_env ? 2 : 1
    #    }
    #    topologySpreadConstraints = [
    #      {
    #        maxSkew           = 1
    #        topologyKey       = "topology.kubernetes.io/zone"
    #        whenUnsatisfiable = "ScheduleAnyway"
    #        labelSelector     = {
    #          matchLabels = {
    #            app = "istio-ingressgateway"
    #          }
    #        }
    #      }
    #    ]

    service = {
      externalTrafficPolicy = "Local"
      type                  = "LoadBalancer"
      ports = [
        {
          name       = "status-port"
          protocol   = "TCP"
          port       = 15021
          targetPort = 15021
        },
        {
          name       = "redis-master"
          protocol   = "TCP"
          port       = 6379
          targetPort = 6379
        },
        {
          name       = "http2"
          protocol   = "TCP"
          port       = 80
          targetPort = 80
        },
        {
          name       = "https"
          protocol   = "TCP"
          port       = 443
          targetPort = 443
        }
      ]
    }
    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "2000m"
        memory = "1042Mi"
      }
    }
  }
}

# Istio Egress Gateway
resource "helm_release" "istio_egress_gateway" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istiod]

  name       = "istio-egressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.istio_version

  values = [
    yamlencode(local.istio_egress_gateway_values)
  ]
}

locals {
  istio_egress_gateway_values = {
    autoscaling = {
      minReplicas = local.prod_env ? 2 : 1
    }
    topologySpreadConstraints = [
      {
        maxSkew           = 1
        topologyKey       = "topology.kubernetes.io/zone"
        whenUnsatisfiable = "ScheduleAnyway"
        labelSelector = {
          matchLabels = {
            app = "istio-egressgateway"
          }
        }
      }
    ]
    service = {
      type = "ClusterIP"
    }
    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "2000m"
        memory = "1042Mi"
      }
    }
  }
}

# Kiali-server
resource "kubernetes_secret" "kiali_domain_tls" {
  count = var.istio_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.istio[0].metadata[0].name
    name      = "tls-domain"
  }

  data = {
    "tls.crt" = base64decode(var.domain_crt)
    "tls.key" = base64decode(var.domain_key)
  }

  type = "kubernetes.io/tls"
}

resource "helm_release" "kiali" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [
    helm_release.istio_ingress_gateway,
    helm_release.istio_egress_gateway,
    kubernetes_secret.kiali_domain_tls,
    kubernetes_secret.kiali_basic_auth
  ]

  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = kubernetes_namespace.istio[0].metadata[0].name
  version    = var.kiali_version

  values = [
    yamlencode(local.kiali_values)
  ]
}


/*

   To change password of basic-auth, run this command and set output to basic_auth_pass variable
   command: USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})"

*/

resource "kubernetes_secret" "kiali_basic_auth" {
  count = var.istio_enabled ? 1 : 0

  metadata {
    namespace = kubernetes_namespace.istio[0].metadata[0].name
    name      = "kiali-basic-auth"
  }

  data = {
    auth = var.basic_auth_pass
  }
}

locals {
  kiali_values = {
    auth = {
      strategy = "anonymous"
    }
    external_services = {
      prometheus = {
        enabled  = true
        url      = "http://prometheus-server.prometheus.svc.cluster.local"
        use_grpc = false
      }
      grafana = {
        enabled        = false
        in_cluster_url = "http://grafana.grafana.svc.cluster.local"
        use_grpc       = false
      }
      custom_dashboards = {
        enabled = false
      }
      tracing = {
        enabled        = false
        in_cluster_url = "http://jaeger-query.istio-system.svc.cluster.local"
        use_grpc       = false
      }
    }
    server = {
      web_fqdn = local.kiali_domain
    }
    deployment = {
      replicas = 2
      affinity = {
        pod = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [
                      {
                        key      = "app"
                        operator = "In"
                        values = ["kiali"]
                      }
                    ]
                  }
                  topologyKey = "topology.kubernetes.io/zone"
                }
              }
            ]

          }
        }
        ingress = {
          enabled           = true
          additional_labels = local.default_labels
          override_yaml = {
            metadata = {
              annotations = {
                "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
                "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
                "nginx.ingress.kubernetes.io/auth-secret"        = "kiali-basic-auth"
                "nginx.ingress.kubernetes.io/auth-type"          = "basic"
              }
            }
            spec = {
              ingressClassName = "nginx"
              rules = [
                {
                  host = local.kiali_domain
                  http = {
                    paths = [
                      {
                        backend = {
                          service = {
                            name = "kiali"
                            port = {
                              name = "http"
                            }
                          }
                        }
                        path     = "/"
                        pathType = "Prefix"
                      }
                    ]
                  }
                }
              ]
              tls = [
                {
                  hosts = ["*.${var.domain}"]
                  secretName = "tls-domain"
                }
              ]
            }
          }
        }
      }
    }
  }
}