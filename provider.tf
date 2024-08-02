provider "aws" {
  profile = var.profile
  region  = var.region
}

terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "3.7.0"
    }
  }
}