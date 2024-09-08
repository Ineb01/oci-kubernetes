resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_vm_qemu" "this" {
  name = var.vm-name
  desc = "Ubuntu Server"
  target_node = var.proxmox_node
  sshkeys = tls_private_key.this.public_key_openssh
  agent = 1
  vmid = var.id
  clone = "ubuntu-cloud"
  qemu_os = "l26"
  cores = var.cpu_cores
  cpu = "host"
  memory = var.memory
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
          size                 = "${var.storage_size}G"
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
  ciuser = var.user
  ipconfig0 = "ip=${var.ip}/${var.ip_subnet_size},gw=${var.ip_gw}"
}

output "tls_private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
}

output "ip" {
  value = var.ip
}

output "user" {
  value = var.user
}