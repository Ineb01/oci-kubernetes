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
    "${file("${path.module}/values.yaml")}"
  ]
  namespace = kubernetes_namespace.argocd.metadata[0].name
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name = "argocd-server-tls"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "tls.crt" = var.certificate
    "tls.key" = var.private_key
  }

  type = "kubernetes.io/tls"
}