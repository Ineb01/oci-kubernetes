resource "aws_ssm_parameter" "secrets" {
  name  = "/oci-cluster/secrets"
  type  = "SecureString"
  value = "-"
  lifecycle {
    ignore_changes = [ value ]
  }
}

output "secrets" {
  value     = aws_ssm_parameter.secrets.value
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
