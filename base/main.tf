module "argocd-deployment" {
  source = "../modules/argocd"
  certificate = var.certificate
  private_key = var.private_key
}

module "ingress" {
  source = "../modules/ingress"
  certificate = var.certificate
  private_key = var.private_key
}