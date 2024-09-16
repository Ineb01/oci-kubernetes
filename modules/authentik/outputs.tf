output "akadmin_pw" {
  value = random_password.authentik_admin_pw.result
  sensitive = true
}
