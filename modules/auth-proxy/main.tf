
data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "this" {
  external_host = "https://${var.external-domain}"
  internal_host = "http://${var.svc-name}.${var.svc-namespace}.svc.cluster.local:${var.svc-port}"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  name = var.name
}

resource "authentik_application" "this" {
  name              = var.display_name
  slug              = var.name
  protocol_provider = authentik_provider_proxy.this.id
}

resource "authentik_outpost" "this" {
  name = var.name
  protocol_providers = [authentik_provider_proxy.this.id]
  service_connection = "88fa3260-a0bc-4be4-a7e5-687745600bb9"

  config = jsonencode({
    log_level: "info"
    authentik_host: "https://authentik.cluster.dphx.eu"
    refresh_interval: "minutes=5"
    kubernetes_replicas: 1
    kubernetes_namespace: var.authentik-namespace
    object_naming_template: "ak-outpost-%(name)s"
    authentik_host_insecure: false
    kubernetes_service_type: "ClusterIP"
    kubernetes_ingress_class_name: var.ingress-class
    kubernetes_ingress_secret_name: "authentik-outpost-tls"
  })
}