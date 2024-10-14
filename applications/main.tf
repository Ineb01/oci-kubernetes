


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
    repoURL: https://github.com/Ineb01/k8s-static-web
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
  outpost_kubernetes_integration_id = var.outpost_kubernetes_integration_id
}

resource "kubernetes_manifest" "vsc-server" {
  manifest = yamldecode(<<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vscode-server
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ineb01/vsc-server-setup.git
    path: .
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: applications
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - Replace=true
EOF
)
}

module "reverse-proxy-vsc" {
  source = "../modules/auth-proxy"
  svc-name = "vscode-server"
  svc-namespace = "applications"
  svc-port = 8443
  display_name = "VSCode"
  name = "vsc"
  external-domain = "vsc.cluster.dphx.eu"
  outpost_kubernetes_integration_id = var.outpost_kubernetes_integration_id
}