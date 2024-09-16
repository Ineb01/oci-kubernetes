variable "domain" {
  type = string
}

variable "authentik_admin_token" {
  type = string
  sensitive = true
}