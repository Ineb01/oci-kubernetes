module "argocd-deployment" {
  source = "./modules/argocd"
}

module "coredns" {
  source = "./modules/coredns"
}

module "proxy" {
  source = "./modules/proxy"
}

module "proxmox-node-1" {
  source = "./modules/ubuntu-nodes/proxmox"
  ip = "192.168.1.32"
  vm-name = "k3s-home-01"
  proxmox_node = var.proxmox_node
  id = 100
}

module "proxmox-node-2" {
  source = "./modules/ubuntu-nodes/proxmox"
  ip = "192.168.1.33"
  vm-name = "k3s-home-02"
  proxmox_node = var.proxmox_node
  id = 101
}