resource "kubernetes_namespace" "coredns" {
  metadata {
    name = "coredns"
  }
}

resource "helm_release" "coredns" {
  name       = "coredns"
  repository = "https://coredns.github.io/helm"
  chart      = "coredns"
  version    = "1.32.0"
  values = [
    "${file("${path.module}/values.yaml")}"
  ]
  namespace = kubernetes_namespace.coredns.metadata[0].name
}

