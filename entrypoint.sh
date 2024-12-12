#!/bin/bash
set -e

# Check for the required Terraform command
if [ "$1" != "apply" ] && [ "$1" != "destroy" ]; then
  echo "Invalid command. Use 'apply' or 'destroy'."
  exit 1
fi

# Run Terraform commands
terraform init -input=false
terraform plan -input=false
terraform $1 -input=false -auto-approve
