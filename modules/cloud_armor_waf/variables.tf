variable "project_id" {
  description = "The ID of the GCP project in which to create the Cloud Armor policy."
  type        = string
}

variable "policy_name" {
  description = "Name of the Cloud Armor security policy."
  type        = string
}

variable "description" {
  description = "Description for the Cloud Armor security policy."
  type        = string
  default     = "PCI DSS compliant Cloud Armor WAF policy"
}

variable "default_rule_action" {
  description = "Action for the default catch-all rule (e.g. allow, deny(403))."
  type        = string
  default     = "allow"
}

variable "allowed_cidr_ranges" {
  description = "Optional list of CIDR ranges to explicitly allow before WAF evaluation."
  type        = list(string)
  default     = []
}

variable "target_backend_services" {
  description = "List of backend service self links that should be protected by the policy."
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Whether to enable Cloud Armor logging on all rules."
  type        = bool
  default     = true
}

variable "preview_owasp_rules" {
  description = "Whether to run the OWASP preconfigured rules in preview mode. Set to false to enforce."
  type        = bool
  default     = false
}

variable "rate_limit_threshold" {
  description = "Rate limiting thresholds for sensitive endpoints."
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
  description = "Key on which to enforce rate limiting (e.g. ALL, IP, HTTP_HEADER, XFF_IP)."
  type        = string
  default     = "ALL"
}

variable "json_parsing" {
  description = "How Cloud Armor should parse JSON payloads (STANDARD or DISABLED)."
  type        = string
  default     = "STANDARD"
}
