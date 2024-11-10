resource "helm_release" "vmware_exporter" {
  count = var.vmware_exporter_enabled ? 1 : 0
  depends_on = [helm_release.prometheus]

  chart      = "vmware-exporter"
  repository = "https://kremers.github.io"
  name       = "kremers"
  namespace  = "exporters"

  values = [
    yamlencode(local.vmware_exporter_values)
  ]
}

locals {
  vmware_exporter_values = {
    replicaCount = 1
    vsphere = {
      user      = var.vsphere_user
      host      = var.vsphere_server
      password  = var.vsphere_password
      ignoressl = true
      specsSize = 2000
      collectors = {
        hosts      = true
        datastores = true
        vms        = true
        snapshots  = true
      }
    }
    podAnnotations = {
      "prometheus.io/scrape" = "false"
      "prometheus.io/port"   = "9272"
      "prometheus.io/path"   = "/metrics"
    }
    service = {
      enabled = true
      port    = 80
    }
  }
}