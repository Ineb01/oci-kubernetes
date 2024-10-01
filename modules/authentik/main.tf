resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "helm_release" "authentik" {
  name       = "authentik"
  repository = "https://charts.goauthentik.io/"
  chart      = "authentik"
  version    = "2024.8.2"
  values = [
    templatefile(
      "${path.module}/values.yaml", 
      {
        authentik_token       = random_password.authentik_token.result,
        postgres_pw           = random_password.postgres_pw.result
        authentik_admin_pw    = random_password.authentik_admin_pw.result,
        authentik_admin_token = var.authentik_admin_token,
        domain                = var.domain
      }
    )
  ]
  namespace = kubernetes_namespace.authentik.metadata[0].name
}

resource "random_password" "authentik_token" {
  length           = 50
  special          = true
  override_special = "!#$%"
}

resource "random_password" "authentik_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%"
}

resource "random_password" "postgres_pw" {
  length           = 16
  special          = true
  override_special = "!#$%"
}