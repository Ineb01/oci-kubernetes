module "argocd-deployment" {
  source = "../modules/argocd"
}

module "coredns" {
  source = "../modules/coredns"
}

module "proxy" {
  source = "../modules/proxy"
}
