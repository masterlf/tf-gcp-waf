locals {
  owasp_preconfigured_rules = [
    {
      name        = "xss"
      priority    = 1000
      description = "Block cross-site scripting attacks"
      expression  = "evaluatePreconfiguredWaf('xss-v33-canary')"
    },
    {
      name        = "sql-injection"
      priority    = 1010
      description = "Block SQL injection attacks"
      expression  = "evaluatePreconfiguredWaf('sqli-v33-canary')"
    },
    {
      name        = "remote-file-inclusion"
      priority    = 1020
      description = "Block remote file inclusion attacks"
      expression  = "evaluatePreconfiguredWaf('rfi-v33-canary')"
    },
    {
      name        = "local-file-inclusion"
      priority    = 1030
      description = "Block local file inclusion attacks"
      expression  = "evaluatePreconfiguredWaf('lfi-v33-canary')"
    },
    {
      name        = "remote-code-execution"
      priority    = 1040
      description = "Block remote code execution attempts"
      expression  = "evaluatePreconfiguredWaf('rce-v33-canary')"
    },
    {
      name        = "command-injection"
      priority    = 1050
      description = "Block command injection attempts"
      expression  = "evaluatePreconfiguredWaf('commandinjection-v33-canary')"
    },
    {
      name        = "protocol-anomalies"
      priority    = 1060
      description = "Block requests with protocol anomalies"
      expression  = "evaluatePreconfiguredWaf('protocolanomalies-v33-canary')"
    },
    {
      name        = "method-enforcement"
      priority    = 1070
      description = "Block unexpected HTTP methods"
      expression  = "evaluatePreconfiguredWaf('methodenforcement-v33-canary')"
    },
    {
      name        = "session-fixation"
      priority    = 1080
      description = "Block session fixation attempts"
      expression  = "evaluatePreconfiguredWaf('sessionfixation-v33-canary')"
    },
    {
      name        = "java-attacks"
      priority    = 1090
      description = "Block Java-based attack payloads"
      expression  = "evaluatePreconfiguredWaf('java-v33-canary')"
    }
  ]
}

resource "google_compute_security_policy" "waf" {
  project     = var.project_id
  name        = var.policy_name
  description = var.description
  type        = "CLOUD_ARMOR"

  advanced_options_config {
    json_parsing = var.json_parsing
    log_level    = "VERBOSE"
  }

  dynamic "rule" {
    for_each = length(var.allowed_cidr_ranges) == 0 ? [] : [1]

    content {
      priority    = 100
      description = "Allow trusted CIDR ranges"
      action      = "allow"

      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.allowed_cidr_ranges
        }
      }

      log_config {
        enable = var.enable_logging
      }
    }
  }

  dynamic "rule" {
    for_each = local.owasp_preconfigured_rules

    content {
      priority    = rule.value.priority
      description = rule.value.description
      action      = "deny(403)"
      preview     = var.preview_owasp_rules

      match {
        expr {
          expression = rule.value.expression
        }
      }

      log_config {
        enable = var.enable_logging
      }
    }
  }

  rule {
    priority    = 2000
    description = "PCI DSS - Rate limit sensitive endpoints"
    action      = "deny(429)"

    match {
      expr {
        expression = "request.path.matches('/(login|admin|checkout).*')"
      }
    }

    rate_limit_options {
      enforce_on_key = var.rate_limit_enforce_on_key
      exceed_action  = "deny(429)"

      rate_limit_threshold {
        count        = var.rate_limit_threshold.count
        interval_sec = var.rate_limit_threshold.interval_seconds
      }
    }

    log_config {
      enable = var.enable_logging
    }
  }

  rule {
    priority    = 2147480000
    description = "Default rule"
    action      = var.default_rule_action

    match {
      expr {
        expression = "true"
      }
    }

    log_config {
      enable = var.enable_logging
    }
  }
}

resource "google_compute_security_policy_association" "attachments" {
  for_each = {
    for backend in var.target_backend_services :
      backend => substr(sha1(backend), 0, 8)
  }

  name             = "${var.policy_name}-${each.value}"
  security_policy  = google_compute_security_policy.waf.id
  target_resource  = each.key
  project          = var.project_id
}
