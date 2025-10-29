#!/usr/bin/env bash
# Destroy stack for a given tfvars file
set -euo pipefail
TFVARS=${1:-envs/client-demo.tfvars}
terraform destroy -auto-approve -var-file="$TFVARS"
