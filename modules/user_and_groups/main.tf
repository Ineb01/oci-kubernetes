resource "authentik_user" "name" {
  username = var.user.username
  name     = var.user.name
  email    = var.user.email
  type     = "internal"
  path     = "goauthentik.io/sources/github"
  attributes = jsonencode({
    "goauthentik.io/user/sources" = ["GitHub"]
  })
  groups = var.user.superuser ? [var.superuser_group] : []
  lifecycle {
    ignore_changes = [ groups ]
  }
}
