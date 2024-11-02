terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.9"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }

    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.0"
    }

    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.10"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
  }
  required_version = ">= 1.9.0"

  backend "local" {}
}

provider "vsphere" {
  user                 = var.username
  password             = var.password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
}


# PRODUCTION PROVIDERS

provider "harbor" {
  url      = "https://${module.rke2_prod_cluster.production_outputs.harbor_domain}"
  username = "admin"
  password = var.general_password
  alias    = "prod"
}


# CENTRALIZED VAULT ON PRODUCTION
provider "vault" {
  address         = "https://${module.rke2_prod_cluster.production_outputs.vault_domain}"
  skip_tls_verify = true
  token           = var.vault_admin_token
  alias           = "prod"
}

# CENTRALIZED ARGOCD ON PRODUCTION
provider "argocd" {
  server_addr = module.rke2_prod_cluster.production_outputs.argocd_domain
  username    = "admin"
  password    = var.general_password
  alias       = "prod"
}

provider "helm" {
  kubernetes {
    host                   = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
    client_certificate     = base64decode(var.client_certificate_prod)
    client_key             = base64decode(var.client_key_prod)
    cluster_ca_certificate = base64decode(var.cluster_ca_cert_prod)
  }
  alias = "prod"
}

provider "kubernetes" {
  host                   = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
  alias                  = "prod"
  client_certificate     = base64decode(var.client_certificate_prod)
  client_key             = base64decode(var.client_key_prod)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_prod)
}

provider "kubectl" {
  host                   = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
  apply_retry_count      = 5
  load_config_file       = false
  alias                  = "prod"
  client_certificate     = base64decode(var.client_certificate_prod)
  client_key             = base64decode(var.client_key_prod)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_prod)
}

# STAGING PROVIDERS
provider "helm" {
  alias = "stage"
  kubernetes {
    host                   = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
    client_certificate     = base64decode(var.client_certificate_stage)
    client_key             = base64decode(var.client_key_stage)
    cluster_ca_certificate = base64decode(var.cluster_ca_cert_stage)
  }
}

provider "kubernetes" {
  alias                  = "stage"
  host                   = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
  client_certificate     = base64decode(var.client_certificate_stage)
  client_key             = base64decode(var.client_key_stage)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_stage)
}

provider "kubectl" {
  alias                  = "stage"
  host                   = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
  client_certificate     = base64decode(var.client_certificate_stage)
  client_key             = base64decode(var.client_key_stage)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_stage)
  apply_retry_count      = 5
  load_config_file       = false
}

# DEVELOPMENT PROVIDERS
provider "helm" {
  alias = "dev"
  kubernetes {
    host                   = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
    client_certificate     = base64decode(var.client_certificate_dev)
    client_key             = base64decode(var.client_key_dev)
    cluster_ca_certificate = base64decode(var.cluster_ca_cert_dev)
  }
}

provider "kubernetes" {
  alias                  = "dev"
  host                   = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
  client_certificate     = base64decode(var.client_certificate_dev)
  client_key             = base64decode(var.client_key_dev)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_dev)
}

provider "kubectl" {
  alias                  = "dev"
  host                   = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
  client_certificate     = base64decode(var.client_certificate_dev)
  client_key             = base64decode(var.client_key_dev)
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_dev)
  apply_retry_count      = 5
  load_config_file       = false
}

