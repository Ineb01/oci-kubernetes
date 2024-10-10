


resource "kubernetes_manifest" "hello-static" {
  manifest = yamldecode(<<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 'hello-static'
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ineb01/k8s-redirecter
    path: .
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
)
}

module "reverse-proxy-hello-static" {
  source = "../modules/auth-proxy"
  svc-name = "nginx-svc"
  svc-namespace = "hello-static"
  svc-port = 80
  display_name = "Hello Static"
  name = "hello-static"
  external-domain = "hellostatic.cluster.dphx.eu"
}

