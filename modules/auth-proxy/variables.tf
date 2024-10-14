variable "display_name" {
  type = string
}

variable "name" {
  type = string
}

variable "svc-namespace" {
  type = string
}

variable "svc-name" {
  type = string
}

variable "svc-port" {
  type = number
}

variable "external-domain" {
  type = string
}

variable "authentik-namespace" {
  type = string
  default = "authentik"
}

variable "ingress-class" {
  type = string
  default = "nginx"
}

variable "outpost_kubernetes_integration_id" {
  type = string
}
