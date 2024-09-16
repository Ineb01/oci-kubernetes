module "argocd-deployment" {
  source = "../modules/argocd"
  domain = var.argocd_domain
}

module "ingress" {
  source = "../modules/ingress"
  certificate = var.certificate
  private_key = var.private_key
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

data "authentik_brand" "authentik-default" {
  domain = "authentik-default"
}

output "name" {
  value = data.authentik_brand.authentik-default.id
}