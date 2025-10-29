resource "kubernetes_secret" "github_models" {
  metadata {
    name      = "github-models"
    namespace = "applications"
  }

  data = {
    API_KEY = var.github_models_api_key
  }
}
