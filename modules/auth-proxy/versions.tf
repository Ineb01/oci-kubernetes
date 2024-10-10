terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.8.3"
    }
  }
}