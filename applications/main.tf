resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
  }
}

resource "kubernetes_manifest" "applications" {
  manifest = yamldecode(<<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: applications
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ineb01/argo-applications.git
    path: .
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - Replace=true
EOF
)
  depends_on = [kubernetes_namespace.applications]
}
