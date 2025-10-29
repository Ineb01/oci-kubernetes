resource "kubernetes_secret" "litellm_openai" {
  metadata {
    name      = "litellm-openai"
    namespace = "applications"
  }

  data = {
    OPENAI_API_KEY = var.litellm_openai_api_key
  }
}
