variable "project_id" {
  description = "The GCP project where the WAF will be deployed."
  type        = string
}

variable "policy_name" {
  description = "The name to assign to the Cloud Armor security policy."
  type        = string
}

variable "policy_description" {
  description = "Description for the Cloud Armor policy."
  type        = string
  default     = "Production PCI DSS Cloud Armor policy"
}

variable "default_rule_action" {
  description = "Default action for unmatched traffic (allow or deny)."
  type        = string
  default     = "allow"
}

variable "allowed_cidr_ranges" {
  description = "Trusted CIDR ranges that bypass WAF evaluation."
  type        = list(string)
  default     = []
}

variable "target_backend_services" {
  description = "Backend service self links that require Cloud Armor protection."
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable WAF logging."
  type        = bool
  default     = true
}

variable "preview_owasp_rules" {
  description = "Set to true to run OWASP rules in preview before enforcing."
  type        = bool
  default     = false
}

variable "rate_limit_threshold" {
  description = "Rate limit configuration for PCI DSS sensitive endpoints."
  type = object({
    count            = number
    interval_seconds = number
  })
  default = {
    count            = 600
    interval_seconds = 60
  }
}

variable "rate_limit_enforce_on_key" {
  description = "Key on which rate limiting is enforced."
  type        = string
  default     = "ALL"
}

variable "json_parsing" {
  description = "JSON parsing configuration for Cloud Armor."
  type        = string
  default     = "STANDARD"
}
