resource "kubernetes_namespace" "ingress-controller" {
  metadata {
    name = "ingress-controller"
  }
}

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress-controller.metadata[0].name
  version    = "4.4.2"
  values = [
    templatefile("${path.module}/values.yaml", {
      namespace = kubernetes_namespace.ingress-controller.metadata[0].name
      secret_name = kubernetes_secret.tls_secret.metadata[0].name
    })
  ]
}

resource "kubernetes_service" "proxmox" {
  metadata {
    name = "proxmox"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
  }
  spec {
    port {
      port        = 8006
      target_port = 8006
    }
    cluster_ip = "None"
    type = "ClusterIP"
  }
}

resource "kubernetes_endpoints" "proxmox" {
  metadata {
    name = "proxmox"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
  }
  subset {
    address {
      ip = "192.168.1.99"
    }
    port {
      port     = 8006
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "proxmox-ingress" {
  metadata {
    name = "proxmox-ingress"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.proxmox_domain
      http {
        path {
          backend {
            service {
              name = "proxmox"
              port {
                number = 8006
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_service" "router" {
  metadata {
    name = "router"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
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
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
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

resource "kubernetes_ingress_v1" "router-ingress" {
  metadata {
    name = "router-ingress"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.router_domain
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
  }
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name = "tls-secret"
    namespace = kubernetes_namespace.ingress-controller.metadata[0].name
  }

  data = {
    "tls.crt" = var.certificate
    "tls.key" = var.private_key
  }

  type = "kubernetes.io/tls"
}
