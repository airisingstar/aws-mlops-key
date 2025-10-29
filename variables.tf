# ------------------------------------------------------------
# Universal input variables
# ------------------------------------------------------------

# AWS region to deploy resources into (e.g., us-east-1)
variable "region"       { type = string }

# Prefix used in names for all resources (e.g., "demo", "clientx")
variable "name_prefix"  { type = string }

# Text label for the environment (e.g., "staging" or "prod")
variable "environment"  { type = string, default = "staging" }

# VPC CIDR range (use a unique range per environment/client)
variable "vpc_cidr"     { type = string, default = "10.18.0.0/16" }
