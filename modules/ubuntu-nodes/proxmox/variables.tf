variable "proxmox_node" {
  type = string
}

variable "id" {
  type = number
}

variable "vm-name" {
  type = string
}

variable "ip" {
  type = string
}

variable "ip_subnet_size" {
  type = number
  default = 24
}

variable "ip_gw" {
  type = string
  default = "192.168.1.1"
}

variable "user" {
  type = string
  default = "ubuntu"
}

variable "cpu_cores" {
  type = number
  default = 2
}

variable "memory" {
  type = number
  default = 4096
}

variable "storage_size" {
  type = number
  default = 10
}