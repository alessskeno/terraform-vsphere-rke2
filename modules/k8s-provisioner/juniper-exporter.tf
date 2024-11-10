resource "helm_release" "juniper_exporter" {
  count = var.juniper_exporter_enabled ? 1 : 0
  depends_on = [
    helm_release.prometheus,
    kubernetes_secret.juniper_exporter
  ]

  name      = "junos-exporter"
  chart     = "${path.root}/files/charts/junosexporter"
  namespace = "exporters"

  values = [
    yamlencode(local.juniper_exporter_values)
  ]
}

locals {
  juniper_exporter_values = {
    # sshkey = var.juniper_exporter_enabled_sshkey # generate sshkey with `cat $HOME/.ssh/id_rsa | base64 -w0 && echo`
    extraArgs = [
      "-ssh.targets=$(JUNIPER_EXPORTER_SSH_TARGETS)",
      "-ssh.user=$(JUNIPER_EXPORTER_SSH_USER)",
      "-ssh.password=$(JUNIPER_EXPORTER_SSH_PASSWORD)"
    ]
    extraEnv = [
      {
        name = "JUNIPER_EXPORTER_SSH_TARGETS"
        valueFrom = {
          secretKeyRef = {
            name = "juniper-exporter"
            key  = "targets"
          }
        }
      },
      {
        name = "JUNIPER_EXPORTER_SSH_USER"
        valueFrom = {
          secretKeyRef = {
            name = "juniper-exporter"
            key  = "username"
          }
        }
      },
      {
        name = "JUNIPER_EXPORTER_SSH_PASSWORD"
        valueFrom = {
          secretKeyRef = {
            name = "juniper-exporter"
            key  = "password"
          }
        }
      }
    ]
    configyml = {
      devices = [
        {
          host     = "172.18.0.15"
          username = "prometheus"
          password = var.juniper_exporter_password
        },
        {
          host     = "172.18.0.35"
          username = "prometheus"
          password = var.juniper_exporter_password
        }
      ],
      features = {
        alarm                = true
        environment          = false
        bgp                  = true
        ospf                 = false
        isis                 = false
        nat                  = true
        l2circuit            = false
        ldp                  = true
        routes               = true
        routing_engine       = true
        firewall             = false
        interfaces           = true
        interface_diagnostic = false
        interface_queue      = false
        storage              = false
        accounting           = true
        ipsec                = false
        security             = false
        fpc                  = false
        rpki                 = false
        rpm                  = false
        satellite            = false
        system               = true
        power                = true
      }

    }
    serviceMonitor = {
      enabled = false
    }
  }
}

resource "kubernetes_secret" "juniper_exporter" {
  count = var.juniper_exporter_enabled ? 1 : 0
  metadata {
    name      = "juniper-exporter"
    namespace = "exporters"
  }
  data = {
    password = var.juniper_exporter_password
    targets  = "172.18.0.35"
    username = "prometheus"
  }
}
