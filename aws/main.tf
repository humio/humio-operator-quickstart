terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      version = ">= 5.26.0"
    }
    kubernetes = {
      version = "~> 2.23"
    }
    random = {
      version = "~> 3.5.1"
    }
    local = {
      version = "~> 2.4.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Name          = var.cluster_name
      Environment   = var.environment
      App           = "humio"
      DeployVersion = "0.1.0"
      ManagedBy     = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "current" {}
