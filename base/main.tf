module "argocd-deployment" {
  source = "../modules/argocd"
}

module "proxy" {
  source = "../modules/proxy"
}