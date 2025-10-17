resource "kubernetes_secret" "google_ai_studio" {
  metadata {
    name      = "google-ai-studio"
    namespace = "applications"
  }

  data = {
    API_KEY = var.google_ai_studio_api_key
  }
}
