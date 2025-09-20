# Cloud Armor WAF Module

This module provisions a Google Cloud Armor security policy tailored for PCI DSS workloads. It enables the Cloud Armor preconfigured rules that map to the OWASP Top 10, enforces a rate-limiting guardrail on sensitive endpoints, and optionally associates the policy with backend services.

## Features

- Enables the latest Cloud Armor preconfigured WAF rules for the OWASP Top 10 categories.
- Provides a PCI DSS aligned baseline through rate limiting, logging, and optional trusted network allow lists.
- Supports attaching the policy to multiple backend services via security policy associations.
- Exposes tunable inputs for logging, JSON parsing, and default rule enforcement.

## Usage

```hcl
module "cloud_armor_waf" {
  source  = "../../modules/cloud_armor_waf"
  project_id = var.project_id
  policy_name = "prod-waf"

  allowed_cidr_ranges        = ["198.51.100.0/24"]
  default_rule_action        = "deny(403)"
  target_backend_services    = [google_compute_backend_service.app.self_link]
  rate_limit_threshold = {
    count            = 300
    interval_seconds = 60
  }
}
```

Refer to the [`variables.tf`](./variables.tf) file for the full list of inputs and their defaults.
