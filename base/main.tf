module "argocd-deployment" {
  source = "../modules/argocd"
  domain = var.argocd_domain
  depends_on = [ module.ingress, module.authentik-deployment ]
}

module "ingress" {
  source = "../modules/ingress"
  certificate = var.certificate
  private_key = var.private_key
  router_domain = var.router_domain
  proxmox_domain = var.proxmox_domain

}

module "authentik-deployment" {
  source = "../modules/authentik"
  domain = var.authentik_domain
  authentik_admin_token = var.authentik_admin_token
  depends_on = [ module.ingress ]
}

output "authentik_admin_pw" {
  value = module.authentik-deployment.akadmin_pw
  sensitive = true
}

data "authentik_brand" "authentik-default" {
  domain = "authentik-default"
  depends_on = [ module.authentik-deployment ]
}

data "authentik_flow" "default-source-authentication" {
  slug = "default-source-authentication"
  depends_on = [ module.authentik-deployment ]
}
data "authentik_flow" "default-source-enrollment" {
  slug = "default-source-enrollment"
  depends_on = [ module.authentik-deployment ]
}

resource "authentik_source_oauth" "name" {
  name                = "GitHub"
  slug                = "github"
  authentication_flow = data.authentik_flow.default-source-authentication.id
  enrollment_flow     = data.authentik_flow.default-source-enrollment.id

  provider_type   = "github"
  consumer_key    = var.github_clientid
  consumer_secret = var.github_clientsecret
  depends_on = [ module.authentik-deployment ]
  lifecycle {
    ignore_changes = [ oidc_jwks_url ]
  }
}