# ------------------------------------------------------------
# Terraform + AWS provider versions
# ------------------------------------------------------------
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0"
    }
  }
}

# Default AWS provider; region comes from variables.tf / tfvars
provider "aws" {
  region = var.region
}
