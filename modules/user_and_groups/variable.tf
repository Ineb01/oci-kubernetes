variable "user" {
  type = object({
    username = string
    name = string
    email = string
  })
}