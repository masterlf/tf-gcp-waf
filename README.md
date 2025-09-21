# Google Cloud Armor Terraform Reference Architecture

This repository provides a production-ready Terraform implementation of Google Cloud Armor for workloads subject to PCI DSS. The configuration enables Cloud Armor's latest preconfigured Web Application Firewall (WAF) protections that align with the [OWASP Top 10](https://owasp.org/www-project-top-ten/), adds PCI-focused guardrails such as rate limiting and logging, and includes automated tests to support regression and lifecycle management.

## Solution Overview

- **Cloud Armor Security Policy** &mdash; Deploys a reusable WAF policy with:
  - Preconfigured rule sets covering the OWASP Top 10 attack categories.
  - Optional allow-listing of trusted networks for administrative access.
  - PCI-aligned rate limiting for sensitive authentication and payment endpoints.
  - Verbose logging to support incident response and compliance evidence collection.
- **Modular Design** &mdash; A single module encapsulates the policy logic and can be re-used across environments.
- **Environment Configuration** &mdash; The `environments/prod` folder shows how to consume the module for a production deployment.
- **Automated Testing** &mdash; Terraform test cases validate critical safeguards (OWASP coverage, rate limiting) without calling Google Cloud APIs by mocking providers.

## Repository Layout

```
├── environments
│   └── prod
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       └── variables.tf
├── modules
│   └── cloud_armor_waf
│       ├── main.tf
│       ├── outputs.tf
│       ├── README.md
│       └── variables.tf
├── tests
│   └── cloud_armor_waf
│       └── policy.tftest.hcl
├── .gitignore
└── versions.tf
```

## Prerequisites

- Terraform **1.6.0 or newer**.
- Google Cloud provider **5.21.0 or newer**.
- A Google Cloud project with billing enabled and the `compute.googleapis.com` API activated.
- IAM permissions to manage Cloud Armor (typically `roles/compute.securityAdmin`).

## Usage

1. Copy the example variables file and update the values for your project:
   ```bash
   cd environments/prod
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Review and adjust the variables in `terraform.tfvars` to match your environment, including backend services that should be protected.
3. Initialise the working directory and review the planned infrastructure:
   ```bash
   terraform init
   terraform validate
   terraform plan
   ```
4. Apply the configuration when ready:
   ```bash
   terraform apply
   ```

## Key Variables

- `allowed_cidr_ranges` &mdash; Trusted CIDR blocks granted access before WAF inspection (useful for admin access).
- `default_rule_action` &mdash; Default fall-through behaviour (`allow` for monitoring mode, `deny(403)` for fail-closed enforcement).
- `target_backend_services` &mdash; List of backend service self links (Global HTTP(S) LB, PSC, etc.) that must inherit the security policy.
- `rate_limit_threshold` &mdash; Controls the PCI DSS rate limiting rule (request count and interval).

See [`modules/cloud_armor_waf/variables.tf`](modules/cloud_armor_waf/variables.tf) for the full set of inputs.

## Compliance Considerations

| Requirement | Implementation Detail |
|-------------|-----------------------|
| OWASP Top 10 Coverage | Cloud Armor preconfigured rules for XSS, SQLi, RCE, LFI/RFI, session fixation, command injection, protocol anomalies, and method enforcement are enabled by default. |
| PCI DSS 6.6 (WAF) | Traffic inspection, logging, and rate limiting for authentication/payment endpoints deliver compensating controls for custom applications. |
| PCI DSS 10 (Logging) | Logging is enabled on every rule and Cloud Armor advanced logging is set to verbose to support audit trails. |
| PCI DSS 12 (Change Management) | Version-controlled Terraform with automated tests (`terraform test`) documents and validates changes prior to deployment. |

## Testing

Automated tests ensure the module continues to deploy the expected safeguards as the configuration evolves.

```bash
terraform fmt -recursive
terraform validate ./environments/prod
terraform test
```

The tests mock the Google provider so that no Google Cloud credentials are required during CI execution.

## Continuous Integration and Security Scanning

Every push and pull request automatically triggers the **Infrastructure CI** workflow located in
`.github/workflows/ci.yml`. The pipeline provides fast feedback on infrastructure changes by running the
following stages:

1. **Terraform quality checks** &mdash; Ensures source consistency and buildability by executing
   `terraform fmt -check -recursive`, `terraform validate` on the module and production environment, and
   `terraform test` for regression coverage.
2. **IaC security scan** &mdash; Runs [`tfsec`](https://aquasecurity.github.io/tfsec/) against the repository to flag
   misconfigurations and policy violations before deployment.

To reproduce these checks locally, run the commands above for formatting, validation, and tests, then execute
`docker run --rm -v "$PWD":/src -w /src aquasec/tfsec /src` to perform the same static analysis used in CI.

## Extending the Solution

- Attach the policy to additional backend services by appending their self links to `target_backend_services`.
- Adjust rate limiting thresholds per workload sensitivity.
- Add custom rules (e.g., geo-blocking, additional header inspection) by extending the module with more rule blocks.
- Integrate the configuration with a remote Terraform state backend and CI pipeline for collaborative operations.

## Security Notes

- Deploy in **preview mode** (`preview_owasp_rules = true`) to observe potential impact before enforcing blocks in production.
- Combine this WAF baseline with secure software development practices, vulnerability management, and runtime monitoring to fully meet PCI DSS requirements.

## License

This project is licensed under the terms of the [MIT License](LICENSE).
