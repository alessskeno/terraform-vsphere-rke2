resource "harbor_project" "main" {
  for_each                    = merge(var.namespaces, var.devops_namespaces)
  name                        = each.key
  public                      = each.key == "iac"
  deployment_security         = null # Possible values: critical, high, medium, low, none. # TODO: replace with critical when the time comes.. (never)
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  force_destroy               = false
  cve_allowlist               = []
  storage_quota               = -1

}

# https://goharbor.io/docs/main/working-with-projects/working-with-images/create-tag-retention-rules/
resource "harbor_retention_policy" "main" {
  for_each = harbor_project.main
  scope    = each.value.id
  schedule = "Daily"

  # Rule to retain last 10 images with tag format v.X.X.X
  rule {
    most_recently_pushed = 10
    repo_matching        = "**"
    tag_matching         = "**" # "v[0-9]+\\.[0-9]+\\.[0-9]+"
  }

  # Rule to retain all images for 30 days since last push
  #  rule {
  #    n_days_since_last_push = 30
  #    repo_matching          = "**"
  #    tag_matching           = "**"
  #  }
}

# Retention Policy can not delete images with tag latest or snapshot
#resource "harbor_immutable_tag_rule" "main" {
#  for_each      = harbor_project.main
#  project_id    = each.value.id
#  repo_matching = "**"
#  tag_excluding = "{latest,snapshot}"
#}

resource "harbor_garbage_collection" "main" {
  schedule        = "Daily"
  delete_untagged = true
}

resource "harbor_purge_audit_log" "main" {
  schedule             = "Daily"
  audit_retention_hour = 24
  include_operations   = "create,pull,delete"
}

# resource "harbor_interrogation_services" "main" {
#   vulnerability_scan_policy = "Daily"
# }

resource "harbor_robot_account" "main" {
  name        = "ci_user"
  description = "CI Automation user"
  level       = "system"
  secret      = var.general_password
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    access {
      action   = "push"
      resource = "repository"
    }
    kind      = "project"
    namespace = "*"
  }
}

# Docker Cache
resource "harbor_registry" "dockerhub" {
  provider_name = "docker-hub"
  name          = "docker"
  endpoint_url  = "https://hub.docker.com"
  # without login
}


resource "harbor_project" "docker_remote" {
  name                        = "docker-remote"
  public                      = true
  registry_id                 = harbor_registry.dockerhub.registry_id
  deployment_security         = null
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  force_destroy               = false
  cve_allowlist               = []
  storage_quota               = 10
}

# Microsoft Container Registry
resource "harbor_registry" "mcr" {
  provider_name = "mcr"
  name          = "mcr"
  endpoint_url  = "https://mcr.microsoft.com"
  # without login
}

resource "harbor_project" "mcr_remote" {
  name                        = "mcr-remote"
  public                      = true
  registry_id                 = harbor_registry.mcr.registry_id
  deployment_security         = null
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  force_destroy               = false
  cve_allowlist               = []
  storage_quota               = 10
}