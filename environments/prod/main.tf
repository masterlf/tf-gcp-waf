module "cloud_armor_waf" {
  source = "../../modules/cloud_armor_waf"

  project_id                = var.project_id
  policy_name               = var.policy_name
  description               = var.policy_description
  default_rule_action       = var.default_rule_action
  allowed_cidr_ranges       = var.allowed_cidr_ranges
  target_backend_services   = var.target_backend_services
  enable_logging            = var.enable_logging
  preview_owasp_rules       = var.preview_owasp_rules
  rate_limit_threshold      = var.rate_limit_threshold
  rate_limit_enforce_on_key = var.rate_limit_enforce_on_key
  json_parsing              = var.json_parsing
}
