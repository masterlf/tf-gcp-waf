output "security_policy_name" {
  description = "Name of the Cloud Armor security policy."
  value       = google_compute_security_policy.waf.name
}

output "security_policy_self_link" {
  description = "Self link of the Cloud Armor security policy."
  value       = google_compute_security_policy.waf.self_link
}

output "security_policy_id" {
  description = "ID of the Cloud Armor security policy."
  value       = google_compute_security_policy.waf.id
}
