terraform {
  backend "s3" {
    bucket       = "kode-catalyst-terraform-state"
    key          = "three-tier-infra/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}