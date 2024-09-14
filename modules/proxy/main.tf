resource "kubernetes_namespace" "proxy" {
  metadata {
    name = "proxy"
  }
}

resource "kubernetes_service" "router" {
  metadata {
    name = "router"
    namespace = kubernetes_namespace.proxy.metadata[0].name
  }
  spec {
    port {
      port        = 80
      target_port = 80
    }
    cluster_ip = "None"
    type = "ClusterIP"
  }
}

resource "kubernetes_endpoints" "router" {
  metadata {
    name = "router"
    namespace = kubernetes_namespace.proxy.metadata[0].name
  }
  subset {
    address {
      ip = "192.168.1.1"
    }
    port {
      port     = 80
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "router-proxy-ingress" {
  metadata {
    name = "router-proxy-ingress"
    namespace = kubernetes_namespace.proxy.metadata[0].name
  }

  spec {
    default_backend {
      service {
        name = "router"
        port {
          number = 80
        }
      }
    }
    rule {
      host = "router.local.dphx.eu"
      http {
        path {
          backend {
            service {
              name = "router"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
      hosts = ["proxxxy.local.dphx.eu"]
      secret_name = "tls-secret"
    }
  }
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name = "tls-secret"
    namespace = kubernetes_namespace.proxy.metadata[0].name
  }

  data = {
    "tls.crt" = acme_certificate.certificate.certificate_pem
    "tls.key" = nonsensitive(acme_certificate.certificate.private_key_pem)
  }

  type = "kubernetes.io/tls"
}

#resource "kubernetes_manifest" "traefik-ignore-tls" {
#  manifest = {
#    apiVersion = "traefik.io/v1alpha1"
#    kind       = "ServersTransport"
#
#    metadata = {
#      name = "traefikignore"
#      namespace = kubernetes_namespace.proxy.metadata[0].name
#    }
#
#    spec = {
#      insecureSkipVerify = true
#    }
#  }
#}

