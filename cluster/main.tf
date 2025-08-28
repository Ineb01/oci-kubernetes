resource "random_password" "k3s_token" {
  length           = 16
  special          = true
  override_special = "!#$%"
}

locals {
  kubeconfig = yamldecode(replace(ssh_resource.kubeconfig.result, "127.0.0.1", module.instance.public_ip[0]))
}

resource "tls_private_key" "ssh_tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_vcn" "vnc" {
  compartment_id = var.tenancy_ocid
  cidr_block     = "172.22.0.0/16"
  display_name   = "kubernetes_vnc"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vnc.id
  display_name   = "kubernetes_igw"
}

resource "oci_core_route_table" "rtb" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vnc.id
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
  }
}

resource "oci_core_route_table_attachment" "attachment" {
  subnet_id      = oci_core_subnet.this.id
  route_table_id = oci_core_route_table.rtb.id
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vnc.id
  display_name   = "all-traffic"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "this" {
  cidr_block        = "172.22.1.0/24"
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.vnc.id
  security_list_ids = [oci_core_security_list.security_list.id]
}

module "instance" {
  source                      = "oracle-terraform-modules/compute-instance/oci"
  compartment_ocid            = var.tenancy_ocid
  instance_display_name       = "kubernetes_node"
  instance_flex_ocpus         = 4
  instance_flex_memory_in_gbs = 24
  source_ocid                 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7sahpriem2mg7m7sfrkafx3iy6u6gjrjnooefs3enasvgw7nfwqq"
  subnet_ocids                = [oci_core_subnet.this.id]
  public_ip                   = "EPHEMERAL"
  ssh_public_keys             = tls_private_key.ssh_tls.public_key_openssh
  boot_volume_size_in_gbs     = 200
  shape                       = "VM.Standard.A1.Flex"
}

resource "time_sleep" "wait_420_seconds" {
  depends_on = [module.instance]

  create_duration = "420s"
}

resource "ssh_resource" "open_firewall" {

  host = module.instance.public_ip[0]
  user = "opc"

  private_key = tls_private_key.ssh_tls.private_key_openssh

  timeout = "15m"

  commands = [
    "sudo systemctl stop firewalld",
    "sudo systemctl disable firewalld",
    "sudo pvresize /dev/sda3",
    "sudo xfs_growfs /"
  ]

  depends_on = [time_sleep.wait_420_seconds]
}

resource "ssh_resource" "install_k3s_1" {

  host = module.instance.public_ip[0]
  user = "opc"

  private_key = tls_private_key.ssh_tls.private_key_openssh

  timeout = "15m"

  commands = [
    "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --cluster-init --write-kubeconfig-mode 644 --node-name k3s-home-01 --tls-san ${module.instance.public_ip[0]}"
  ]

  depends_on = [time_sleep.wait_420_seconds]
}

resource "ssh_resource" "kubeconfig" {

  host = module.instance.public_ip[0]
  user = "opc"

  private_key = tls_private_key.ssh_tls.private_key_openssh

  timeout = "1m"

  commands = [
    "cat /etc/rancher/k3s/k3s.yaml"
  ]
  depends_on = [ssh_resource.install_k3s_1]
}

data "aws_route53_zone" "main" {
  name = var.route53_zone
}

resource "aws_route53_record" "cluster" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "cluster.${var.route53_zone}"
  type    = "A"
  ttl     = 300
  records = [module.instance.public_ip[0]]
}

resource "aws_route53_record" "cluster_wildcard" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.cluster.${var.route53_zone}"
  type    = "A"
  ttl     = 300
  records = [module.instance.public_ip[0]]
}

resource "local_file" "kubeconfig" {
  filename = "/home/benja/.kube/config"
  content  = yamlencode(local.kubeconfig)
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.ssh_tls.private_key_pem
  file_permission = "600"
  filename        = "/home/benja/.ssh/nodes"
}

resource "local_file" "ssh_key_pub" {
  content         = tls_private_key.ssh_tls.public_key_openssh
  file_permission = "755"
  filename        = "/home/benja/.ssh/nodes.pub"
}

output "kubernetes_host" {
  value = local.kubeconfig.clusters[0].cluster.server
}

output "client_certificate" {
  value = local.kubeconfig.users[0].user.client-certificate-data
  sensitive = true
}

output "client_key" {
  value = local.kubeconfig.users[0].user.client-key-data
  sensitive = true
}

output "cluster_ca_certificate" {
  value = local.kubeconfig.clusters[0].cluster.certificate-authority-data
  sensitive = true
}
