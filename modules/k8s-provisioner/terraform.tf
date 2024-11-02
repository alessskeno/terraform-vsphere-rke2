terraform {
  required_providers {
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

    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.10"
    }
  }
}