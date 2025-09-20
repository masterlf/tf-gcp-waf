output "security_policy_name" {
  description = "Name of the Cloud Armor policy protecting the application."
  value       = module.cloud_armor_waf.security_policy_name
}

output "security_policy_self_link" {
  description = "Self link of the Cloud Armor policy for reference and automation."
  value       = module.cloud_armor_waf.security_policy_self_link
}
