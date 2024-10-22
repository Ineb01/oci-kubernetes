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

variable "router_domain" {
  type = string
}

variable "proxmox_domain" {
  type = string
}

variable "authentik_admin_token" {
  type = string
  sensitive = true
}

variable "github_clientid" {
  type = string
}

variable "github_clientsecret" {
  type = string
  sensitive = true
}

variable "users" {
  type = list(object({
    username = string
    name = string
    email = string
    groups = optional(list(string), [])
  }))
}