# https://github.com/longhorn/longhorn/tree/master/chart
# https://longhorn.io/docs/1.5.1/deploy/accessing-the-ui/longhorn-ingress/
# https://longhorn.github.io/longhorn-tests/manual/pre-release/node/improve-node-failure-handling/
# https://longhorn.io/kb/troubleshooting-volume-with-multipath/

# https://longhorn.io/kb/troubleshooting-volume-with-multipath/
/*

   To delete Longhorn patch this command to patch lgh ( settings resource )
   kubectl -n longhorn-system patch -p '{"value": "true"}' --type=merge lhs deleting-confirmation-flag
   To observe current settings: kubectl get setttings (or lhs)

   To change password of basic-auth, run this command and set output to basic_auth_pass variable
   command: USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})"

   Adding Node Tags to New Nodes: https://longhorn.io/docs/1.5.2/advanced-resources/default-disk-and-node-config/
   Taints on the node has to be created accordingly as defined in values:
              key      = "node-role.kubernetes.io/master"
              operator = "Equal"
              value    = "true"
              effect   = "NoSchedule"

   Warning: Bugged feature - does not work - has to be done via UI for now.
    set {
      name  = "defaultSettings.storageReservedPercentageForDefaultDisk"
      value = 5
    }


    Recurring Backup/Snapshot jobs
    https://longhorn.io/docs/archives/1.2.2/snapshots-and-backups/scheduling-backups-and-snapshots/


    Identify the name of the volume you want to label. List all volumes using:
    kubectl -n longhorn-system get lhv

    Edit the volume resource. Replace <volume-name> with your volume's name:
    kubectl -n longhorn-system edit lhv <volume-name>
    ...
    metadata:
      labels:
        longhorn.io/recurring-job-group1: "true"
    ...

    or use kubectl:
    kubectl -n longhorn-system label volume/pvc-8b9cd514-4572-4eb2-836a-ed311e804d2f recurring-job.longhorn.io/group-name=enabled

*/

resource "kubernetes_namespace" "longhorn" {
  count = var.longhorn_enabled ? 1 : 0
  metadata {
    name = "longhorn-system"
  }

  lifecycle {
    precondition {
      condition     = var.cert_manager_enabled == true
      error_message = "Cert Manager must be enabled to deploy Longhorn"
    }
  }
}


resource "helm_release" "longhorn" {
  count = var.longhorn_enabled ? 1 : 0
  depends_on = [
    kubernetes_namespace.longhorn,
    kubernetes_labels.storage_node_labels_az1,
    kubernetes_labels.storage_node_labels_az3
  ]
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace.longhorn[0].metadata[0].name
  version    = var.longhorn_version

  values = [
    yamlencode(local.longhorn_values)
  ]
}

locals {
  lh_nfs_endpoint = "nfs://${local.nfs_ip_az1}:/mnt/nfs_share"

  longhorn_values = {
    ingress = {
      enabled = true
      annotations = {
        "cert-manager.io/cluster-issuer"          = kubectl_manifest.cluster_ca_issuer[0].name
        "nginx.ingress.kubernetes.io/auth-type"   = "basic"
        "nginx.ingress.kubernetes.io/auth-secret" = kubernetes_secret.longhorn_ingress_basic_auth[0].metadata[0].name
        "cert-manager.io/common-name"             = local.longhorn_domain
        "cert-manager.io/subject-organization"    = var.domain
      }
      ingressClassName = "nginx"
      tls              = true
      tlsSecret        = "longhorn-tls"
      host             = local.longhorn_domain
    }
    persistence = {
      defaultClassReplicaCount = 1
      reclaimPolicy            = "Retain"
    }
    defaultSettings = {
      createDefaultDiskLabeledNodes               = true
      replicaSoftAntiAffinity                     = false
      replicaZoneSoftAntiAffinity                 = true
      autoDeletePodWhenVolumeDetachedUnexpectedly = true
      nodeDownPodDeletionPolicy                   = "delete-both-statefulset-and-deployment-pod"
      defaultDataLocality                         = "disabled"
      replicaAutoBalance                          = "disabled"
      backupTarget                                = local.lh_nfs_endpoint
      taintToleration                             = "node-role.kubernetes.io/master=true:NoSchedule"
    },
    longhornManager = {
      tolerations = [
        {
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }
      ]
    }
  }
}

resource "kubernetes_secret" "longhorn_ingress_basic_auth" {
  count = var.longhorn_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.longhorn[0].metadata[0].name
    name      = "basic-auth"
  }
  data = {
    auth = var.basic_auth_pass
  }
}

# Backup Recurring jobs
# Label: recurring-job.longhorn.io/daily=enabled. Labeling with this group name is optional -default groups is included,
# so any volume will adopt this job without a label.
resource "kubectl_manifest" "daily_backup_job" {
  count = var.longhorn_enabled ? 1 : 0
  depends_on = [
    helm_release.longhorn
  ]


  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"
    metadata = {
      name      = "daily-backup"
      namespace = "longhorn-system"
    }
    spec = {
      cron = "0 1 * * *" # UTC Time
      task        = "backup"
      groups = ["default", "daily"]
      retain      = 3
      concurrency = 3
      name        = "daily-backup"
      parameters = {}
      labels = merge(local.default_labels,
        {
          "backup"         = "daily"
          "retention-days" = "3"
        }
      )
    }
  })
}

# Label: recurring-job.longhorn.io/weekly=enabled
resource "kubectl_manifest" "weekly_backup_job" {
  count = var.longhorn_enabled ? 1 : 0
  depends_on = [
    helm_release.longhorn
  ]


  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"
    metadata = {
      name      = "weekly-backup"
      namespace = "longhorn-system"
    }
    spec = {
      cron = "0 23 * * 1" # At 03:00 AM, on Monday, every week.
      task        = "backup"
      groups = ["weekly"]
      retain      = 30
      concurrency = 3
      name        = "weekly-backup"
      parameters = {}
      labels = merge(local.default_labels,
        {
          "backup"         = "weekly"
          "retention-days" = "30"
        }
      )
    }
  })
}

# Label: recurring-job.longhorn.io/monthly=enabled
resource "kubectl_manifest" "monthly_backup_job" {
  count = var.longhorn_enabled ? 1 : 0
  depends_on = [
    helm_release.longhorn
  ]

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"
    metadata = {
      name      = "monthly-backup"
      namespace = "longhorn-system"
    }
    spec = {
      cron = "0 21 1 * *" # At midnight, on the firth day of every month.
      task        = "backup"
      groups = ["monthly"]
      retain      = 90
      concurrency = 3
      name        = "monthly-backup"
      parameters = {}
      labels = merge(local.default_labels,
        {
          "backup"         = "monthly"
          "retention-days" = "90"
        }
      )
    }
  })
}

resource "kubectl_manifest" "filesystem_trim" {
  count = var.longhorn_enabled ? 1 : 0
  depends_on = [
    helm_release.longhorn
  ]
  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"
    metadata = {
      name      = "filesystem-trim"
      namespace = "longhorn-system"
    }
    spec = {
      cron = "0 * * * *" # Every hour
      task = "filesystem-trim"
      groups = ["default"]
      labels = merge(local.default_labels,
        {
          "trim" = "filesystem"
        }
      )
      retain      = 0
      concurrency = 1
      name        = "filesystem-trim"
      parameters = {}
    }
  })
}