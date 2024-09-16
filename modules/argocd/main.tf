resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.4.5"
  values = [
    templatefile(
      "${path.module}/values.yaml", 
      {
        domain                         = var.domain
        argocd_authentik_client_secret = authentik_provider_oauth2.argocd.client_secret
        argocd_authentik_client_id     = authentik_provider_oauth2.argocd.client_id
        argocd_application_slug        = authentik_application.argocd.slug
        argocd_admin_groups            = authentik_group.argocd_admins.name
        argocd_viewer_groups           = authentik_group.argocd_viewers.name
      }
    )
  ]
  namespace = kubernetes_namespace.argocd.metadata[0].name
}


data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_property_mapping_provider_scope" "openid" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-openid"
  ]
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "argocd" {
  name          = "ArgoCD"
  client_id     = "argocd_client"

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  signing_key = data.authentik_certificate_key_pair.generated.id

  redirect_uris = [
    "https://${var.domain}/api/dex/callback"
  ]

  property_mappings = data.authentik_property_mapping_provider_scope.openid.ids
}

resource "authentik_application" "argocd" {
  name              = "ArgoCD"
  slug              = "argocd"
  protocol_provider = authentik_provider_oauth2.argocd.id
}

resource "authentik_group" "argocd_admins" {
  name    = "ArgoCD Admins"
}

resource "authentik_group" "argocd_viewers" {
  name    = "ArgoCD Viewers"
}