variable "outpost_kubernetes_integration_id" {
  type = string
}

variable "google_ai_studio_api_key" {
  type      = string
  sensitive = true
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "github_models_api_key" {
  type      = string
  sensitive = true
}

variable "litellm_openai_api_key" {
  type      = string
  sensitive = true
}