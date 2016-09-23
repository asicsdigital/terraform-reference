#!/bin/bash

# Usage: ./init.sh once to initialize remote storage for this environment.
# Subsequent tf actions in this environment don't require re-initialization,
# unless you have completely cleared your .terraform cache.
#
# terraform plan  -var-file=./production.tfvars
# terraform apply -var-file=./production.tfvars

# tf_env="production"
tf_env="base"

terraform remote config -backend=s3 \
                        -backend-config="bucket=lunchbot-terraform-state" \
                        -backend-config="key=${tf_env}/${tf_env}.tfstate" \
                        -backend-config="region=us-east-1"

echo "set remote s3 state to $tf_env.tfstate"
