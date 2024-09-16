variable "certificate" {
  type = string
}

variable "private_key" {
  type = string
  sensitive = true
}

variable "router_domain" {
  type = string
}

variable "proxmox_domain" {
  type = string
}