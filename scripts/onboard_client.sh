#!/usr/bin/env bash
# Clone the client template and apply in one go.
set -euo pipefail
CLIENT=${1:-demo}
echo "🚀 Onboarding client: $CLIENT"
cp envs/client-template.tfvars "envs/${CLIENT}.tfvars"
echo "name_prefix = \"$CLIENT\"" >> "envs/${CLIENT}.tfvars"
terraform init
terraform apply -auto-approve -var-file="envs/${CLIENT}.tfvars"
