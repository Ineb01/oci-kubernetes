
data "aws_route53_zone" "base_domain" {
  name = "dphx.eu"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "benjamin.bachmayr@gmail.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = "dphx.eu"
  subject_alternative_names = ["*.dphx.eu"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}

output "certificate_pem" {
  value = lookup(acme_certificate.certificate, "certificate_pem")
}

output "issuer_pem" {
  value = lookup(acme_certificate.certificate, "issuer_pem")
}

output "private_key_pem" {
  value = nonsensitive(lookup(acme_certificate.certificate, "private_key_pem"))
}