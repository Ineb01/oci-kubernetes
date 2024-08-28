module "argocd-deployment" {
  source = "./modules/argocd"
}

module "coredns" {
  source = "./modules/coredns"
}

module "proxy" {
  source = "./modules/proxy"
}

output "private_key" {
  value = module.proxy.private_key_pem
}

output "cert" {
  value = module.proxy.certificate_pem
}