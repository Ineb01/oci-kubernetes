variable "certificate" {
  type = string
}

variable "private_key" {
  type = string
  sensitive = true
}

variable "authentik_domain" {
  type = string
}

variable "argocd_domain" {
  type = string
}