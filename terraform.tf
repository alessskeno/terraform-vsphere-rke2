terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~>2.9"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.15"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.32"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.14"
    }

    argocd = {
      source  = "oboukili/argocd"
      version = "~> 6.2"
    }

    harbor = {
        source  = "goharbor/harbor"
        version = "~>3.10"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~>4.4"
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
    host        = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
    config_path = local.kubeconfig_file_path
  }
  alias = "prod"
}

provider "kubernetes" {
  host        = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
  config_path = local.kubeconfig_file_path
  alias       = "prod"
}

provider "kubectl" {
  host              = "https://${cidrhost(var.vm_cidr_az1, 10)}:6443"
  config_path       = "${path.root}/files/kubeconfig/rke2.yaml"
  apply_retry_count = 5
  load_config_file  = true
  alias             = "prod"
}

# STAGING PROVIDERS
provider "helm" {
  alias = "stage"
  kubernetes {
    host        = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
    config_path = local.kubeconfig_file_path
  }
}

provider "kubernetes" {
  alias       = "stage"
  host        = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
  config_path = local.kubeconfig_file_path
}

provider "kubectl" {
  alias             = "stage"
  host              = "https://${cidrhost(var.vm_cidr_az1, 110)}:6443"
  config_path       = "${path.root}/files/kubeconfig/rke2.yaml"
  apply_retry_count = 5
  load_config_file  = true
}

# DEVELOPMENT PROVIDERS
provider "helm" {
  alias = "dev"
  kubernetes {
    host        = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
    config_path = local.kubeconfig_file_path
  }
}

provider "kubernetes" {
  alias       = "dev"
  host        = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
  config_path = local.kubeconfig_file_path
}

provider "kubectl" {
  alias             = "dev"
  host              = "https://${cidrhost(var.vm_cidr_az1, 210)}:6443"
  config_path       = "${path.root}/files/kubeconfig/rke2.yaml"
  apply_retry_count = 5
  load_config_file  = true
}

