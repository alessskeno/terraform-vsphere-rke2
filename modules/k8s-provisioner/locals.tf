locals {

  geo_redundant_tsc = [
    {
      labelSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "rabbitmq"
        }
      }
      maxSkew           = 1
      topologyKey       = "topology.kubernetes.io/zone"
      whenUnsatisfiable = "ScheduleAnyway"
    }
  ]

  az1_affinity_rule = {
    nodeAffinity = {
      preferredDuringSchedulingIgnoredDuringExecution = [
        {
          weight = 1
          preference = {
            matchExpressions = [
              {
                key      = "topology.kubernetes.io/zone"
                operator = "In"
                values = ["az1"]
              }
            ]
          }
        }
      ]
    }
  }

  az3_affinity_rule = {
    nodeAffinity = {
      preferredDuringSchedulingIgnoredDuringExecution = [
        {
          weight = 1
          preference = {
            matchExpressions = [
              {
                key      = "topology.kubernetes.io/zone"
                operator = "In"
                values = ["az3"]
              }
            ]
          }
        }
      ]
    }
  }

  /*  gr_affinity_rule = {
      nodeAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            weight = 1
            preference = {
              matchExpressions = [
                {
                  key      = "node-role.kubernetes.io/gitlab-runners"
                  operator = "In"
                  values   = ["true"]
                }
              ]
            }
          }
        ]
      }
    }*/

  default_labels = {
    "kubernetes.io/environment" = var.env
    "kubernetes.io/owner"       = "Devops"
    "kubernetes.io/managed-by"  = "Terraform"
  }
  cluster_issuer_name = "cluster-ca-issuer"

  custom_dns_enabled = var.external_dns_entries != {} || var.internal_dns_entries != {}
  multi_az           = var.vcloud_project_outputs.multi_az
  master_node_names  = var.vcloud_project_outputs.master_node_names
  worker_node_names  = var.vcloud_project_outputs.worker_node_names
  storage_node_count = var.vcloud_project_outputs.storage_node_count
  worker_node_count  = var.vcloud_project_outputs.worker_node_count

  nfs_ip_az1 = var.vcloud_project_outputs.nfs_ip_az1

  prod_env  = var.env == "prod"
  stage_env = var.env == "stage"
  dev_env   = var.env == "dev"

  harbor_domain       = var.vcloud_project_outputs.harbor_domain
  argocd_domain       = var.vcloud_project_outputs.argocd_domain
  vault_domain        = var.vcloud_project_outputs.vault_domain
  grafana_domain      = var.vcloud_project_outputs.grafana_domain
  gitlab_domain       = "gitlab.${var.domain}"
  sonarqube_domain    = var.vcloud_project_outputs.sonarqube_domain
  longhorn_domain     = var.vcloud_project_outputs.longhorn_domain
  prometheus_domain   = var.vcloud_project_outputs.prometheus_domain
  alertmanager_domain = var.vcloud_project_outputs.alertmanager_domain
  kiali_domain        = var.vcloud_project_outputs.kiali_domain
  rabbitmq_domain     = var.vcloud_project_outputs.rabbitmq_domain
  loki_domain         = var.vcloud_project_outputs.loki_domain
  minio_domain        = var.vcloud_project_outputs.minio_domain


  master_nodes = {
    for v in flatten([
      for az, nodes in local.master_node_names : [
        for node in nodes : {
          name              = node,
          availability_zone = az
        }
      ]
    ]) : v.name => v
  }

  worker_nodes = {
    for v in flatten([
      for az, nodes in local.worker_node_names : [
        for node in nodes : {
          name              = node,
          availability_zone = az
        }
      ]
    ]) : v.name => v
  }

}
