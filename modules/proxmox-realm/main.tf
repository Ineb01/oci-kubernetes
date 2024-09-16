data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
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

resource "authentik_provider_oauth2" "proxmox" {
  name          = "proxmox"
  client_id     = "proxmox_client"

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  signing_key = data.authentik_certificate_key_pair.generated.id

  redirect_uris = [
    "https://proxmox.cluster.dphx.eu"
  ]

  property_mappings = data.authentik_property_mapping_provider_scope.openid.ids
}

resource "authentik_application" "proxmox" {
  name = "Proxmox"
  slug = "proxmox"
  protocol_provider = authentik_provider_oauth2.proxmox.id
}

output "proxmox_command" {
  value = "pamum realm add authentik --type openid --issuer-url http://authentik.cluster.dphx.eu/application/o/proxmox/ --client-id ${authentik_provider_oauth2.proxmox.client_id} --client-key ${authentik_provider_oauth2.proxmox.client_secret} --username-claim username --autocreate 1"
}