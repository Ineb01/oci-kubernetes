module "argocd-deployment" {
  source = "./modules/argocd"
}

module "coredns" {
  source = "./modules/coredns"
}

module "proxy" {
  source = "./modules/proxy"
}

resource "tls_private_key" "master" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_vm_qemu" "srv_demo_1" {
  name = "k3s-01"
  desc = "Ubuntu Server for k3s"
  target_node = var.proxmox_node
  sshkeys = tls_private_key.master.public_key_openssh
  agent = 1
  clone = "ubuntu-cloud"
  qemu_os = "l26"
  cores = 2
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"

  serial {
    id = "0"
    type = "socket"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          discard              = false
          emulatessd           = true
          format               = "raw"
          size                 = "30G"
          storage              = "local-lvm"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  os_type = "cloud-init"
  ciuser = "ubuntu"
  ipconfig0 = "ip=192.168.1.97/24,gw=192.168.1.1"
}