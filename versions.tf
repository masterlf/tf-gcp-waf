terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.21.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.21.0"
    }
  }
}
