data "aws_route53_zone" "base_domain" {
  name = var.domain
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = var.subdomain
  subject_alternative_names = ["*.${var.subdomain}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}

resource "random_password" "authentik_admin_token" {
  length           = 16
  special          = true
  override_special = "!#$%"
}

output "authentik_admin_token" {
  value = random_password.authentik_admin_token.result
  sensitive = true
}

variable "domain" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "email" {
  type = string
}

output "certificate" {
  value = "${acme_certificate.certificate.certificate_pem}\n${acme_certificate.certificate.issuer_pem}"
}

output "private_key" {
  value = acme_certificate.certificate.private_key_pem
  sensitive = true
}