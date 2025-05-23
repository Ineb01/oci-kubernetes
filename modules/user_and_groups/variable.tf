variable "user" {
  type = object({
    username  = string
    name      = string
    email     = string
    superuser = optional(bool, false)
  })
}

variable "superuser_group" {
  description = "The group that will be given superuser access"
  type = string
}