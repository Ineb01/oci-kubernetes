module "argocd-deployment" {
  source = "../modules/argocd"
  domain = var.argocd_domain
}

module "ingress" {
  source = "../modules/ingress"
  certificate = var.certificate
  private_key = var.private_key
  router_domain = var.router_domain
  proxmox_domain = var.proxmox_domain
}

module "authentik-deployment" {
  source = "../modules/authentik"
  domain = var.authentik_domain
  authentik_admin_token = var.authentik_admin_token
}

output "akadmin_pw" {
  value = module.authentik-deployment.akadmin_pw
  sensitive = true
}

module "proxmox_realm" {
  source = "../modules/proxmox-realm"
  domain = var.proxmox_domain
}

data "authentik_brand" "authentik-default" {
  domain = "authentik-default"
}

output "proxmox_command" {
  value = module.proxmox_realm.proxmox_command
  sensitive = true
}