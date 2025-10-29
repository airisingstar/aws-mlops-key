#!/usr/bin/env bash
# Apply a given tfvars file (defaults to client-demo.tfvars)
set -euo pipefail
TFVARS=${1:-envs/client-demo.tfvars}
terraform init
terraform apply -auto-approve -var-file="$TFVARS"
