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
}