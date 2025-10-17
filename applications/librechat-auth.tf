resource "authentik_provider_oauth2" "librechat" {
  name               = "LibreChat"
  client_id          = "librechat"
  client_secret      = random_password.librechat_client_secret.result
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris      = ["https://librechat.cluster.dphx.eu/oauth/openid/callback"]
  property_mappings  = data.authentik_property_mapping_provider_scope.scope-mappings.ids
}

resource "authentik_application" "librechat" {
  name              = "LibreChat"
  slug              = "librechat"
  protocol_provider = authentik_provider_oauth2.librechat.id
}

resource "random_password" "librechat_client_secret" {
  length  = 32
  special = true
}

resource "random_password" "librechat_session_secret" {
  length  = 32
  special = true
}

data "authentik_provider_oauth2_config" "librechat" {
  provider_id = authentik_provider_oauth2.librechat.id
}

resource "kubernetes_secret" "authentik_oidc" {
  metadata {
    name      = "authentik-oidc"
    namespace = "applications"
  }

  data = {
    CLIENT_ID      = authentik_provider_oauth2.librechat.client_id
    CLIENT_SECRET  = authentik_provider_oauth2.librechat.client_secret
    SESSION_SECRET = random_password.librechat_session_secret.result
    ISSUER_URL     = data.authentik_provider_oauth2_config.librechat.issuer_url
  }
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_property_mapping_provider_scope" "scope-mappings" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}
