mock_provider "google" {}
mock_provider "google-beta" {}

run "cloud_armor_waf_plan" {
  command = plan

  module {
    source = "./modules/cloud_armor_waf"
  }

  variables = {
    project_id              = "test-project"
    policy_name             = "test-waf"
    allowed_cidr_ranges     = ["10.0.0.0/8"]
    default_rule_action     = "deny(403)"
    target_backend_services = []
    preview_owasp_rules     = false
    rate_limit_threshold = {
      count            = 200
      interval_seconds = 60
    }
    rate_limit_enforce_on_key = "ALL"
    json_parsing              = "STANDARD"
  }

  assert {
    condition     = contains(keys(plan.resource_changes), "google_compute_security_policy.waf")
    error_message = "Expected the module to create a Cloud Armor security policy."
  }

  assert {
    condition = length([
      for rule in plan.resource_changes.google_compute_security_policy.waf.change.after.rule : rule
      if rule.action == "deny(403)"
    ]) >= 8
    error_message = "Expected OWASP deny rules to be configured."
  }

  assert {
    condition = anytrue([
      for rule in plan.resource_changes.google_compute_security_policy.waf.change.after.rule :
      can(rule.rate_limit_options)
    ])
    error_message = "Expected at least one rate limiting rule for PCI DSS protection."
  }
}
