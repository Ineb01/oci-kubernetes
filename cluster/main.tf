resource "random_password" "k3s_token" {
  length           = 16
  special          = true
  override_special = "!#$%"
}

module "proxmox-node-1" {
  source = "../modules/ubuntu-nodes/proxmox"
  ip = "192.168.1.32"
  vm-name = "k3s-home-01"
  proxmox_node = var.proxmox_node
  id = 100
}

resource "ssh_resource" "install_k3s_1" {

  host         = module.proxmox-node-1.ip
  user         = module.proxmox-node-1.user
  
  private_key = module.proxmox-node-1.tls_private_key

  timeout = "15m"

  commands = [
    "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --cluster-init --disable traefik --write-kubeconfig-mode 644 --node-name k3s-home-01"
  ]

  depends_on = [ module.proxmox-node-1 ]
}

resource "ssh_resource" "kubeconfig" {

  host         = module.proxmox-node-1.ip
  user         = module.proxmox-node-1.user
  
  private_key = module.proxmox-node-1.tls_private_key

  timeout = "1m"

  commands = [
     "cat /etc/rancher/k3s/k3s.yaml"
  ]
  depends_on = [ ssh_resource.install_k3s_1 ]
}

resource "local_file" "kubeconfig" {
  filename = "/home/ineb01/.kube/config"
  content  = replace(ssh_resource.kubeconfig.result, "127.0.0.1", module.proxmox-node-1.ip)
}

resource "local_file" "node1-tls" {
  filename = "./.terraform/node-1"
  content  = module.proxmox-node-1.tls_private_key
}


module "proxmox-node-2" {
  source = "../modules/ubuntu-nodes/proxmox"
  ip = "192.168.1.33"
  vm-name = "k3s-home-02"
  proxmox_node = var.proxmox_node
  id = 101
}

resource "ssh_resource" "install_k3s_2" {

  host         = module.proxmox-node-2.ip
  user         = module.proxmox-node-2.user
  
  private_key = module.proxmox-node-2.tls_private_key

  timeout = "15m"

  commands = [
    "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --server https://192.168.1.32:6443 --disable traefik --node-name k3s-home-02"
  ]
  depends_on = [ ssh_resource.install_k3s_1 ]
}

module "proxmox-node-3" {
  source = "../modules/ubuntu-nodes/proxmox"
  ip = "192.168.1.34"
  vm-name = "k3s-home-03"
  proxmox_node = var.proxmox_node
  id = 102
}

resource "ssh_resource" "install_k3s_3" {

  host         = module.proxmox-node-3.ip
  user         = module.proxmox-node-3.user
  
  private_key = module.proxmox-node-3.tls_private_key

  timeout = "15m"

  commands = [
    "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --server https://192.168.1.32:6443 --disable traefik --node-name k3s-home-03"
  ]
  depends_on = [ ssh_resource.install_k3s_1 ]
}

variable "proxmox_node" {
  type = string
}