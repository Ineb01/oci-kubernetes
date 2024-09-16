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
        domain          = var.domain
      }
    )
  ]
  namespace = kubernetes_namespace.argocd.metadata[0].name
}