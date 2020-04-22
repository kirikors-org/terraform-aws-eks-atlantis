terraform {
  required_version = "~> 0.12.0"

  required_providers {
    aws        = "~> 2.0"
    template   = "~> 2.0"
    null       = "~> 2.0"
    local      = "~> 1.3"
    kubernetes = "~> 1.11"
    helm       = "~> 1.0"
    github     = "~> 2.6"
  }

  # remote state required for atlantis
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kirikors"

    workspaces {
      name = "demo"
    }
  }

}
