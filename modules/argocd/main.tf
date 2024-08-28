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