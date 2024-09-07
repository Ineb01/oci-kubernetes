provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "proxmox" {
  pm_api_token_id = "root@pam!terraform"
  pm_api_token_secret = "7dd43d8a-bf23-47b4-ac82-590e867b9437"
  pm_api_url = "https://proxmox.local.dphx.eu:8006/api2/json/"
  pm_tls_insecure = true
}

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
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
    acme = {
      source = "vancluever/acme"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}