module "argocd-deployment" {
  source = "../modules/argocd"
  domain = var.argocd_domain
  depends_on = [ module.ingress, module.authentik-deployment ]
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
  depends_on = [ module.ingress ]
}

output "authentik_admin_pw" {
  value = module.authentik-deployment.akadmin_pw
  sensitive = true
}

data "authentik_brand" "authentik-default" {
  domain = "authentik-default"
  depends_on = [ module.authentik-deployment ]
}