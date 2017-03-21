#!/bin/bash

# Usage: ./init.sh once to initialize remote storage for this environment.
# Subsequent tf actions in this environment don't require re-initialization,
# unless you have completely cleared your .terraform cache.
#
# terraform plan  -var-file=./production.tfvars
# terraform apply -var-file=./production.tfvars
#
# Make sure you populate the repo's .env file in the root of the repo
source ../.env

if [ -z "$(which terraform 2>/dev/null)" ]; then
  echo "unable to find 'terraform' in \$PATH, exiting."
  exit 1
fi

if [ -z ${TF_PROJECT_NAME} ]; then
  echo "'TF_PROJECT_NAME' is empty, exiting with failure."
  exit 1
fi

set -e

tf_env="base"

aws_default_region="${AWS_DEFAULT_REGION:-us-east-1}"

s3_bucket="rk-devops-state-${aws_default_region}"
s3_prefix="${TF_PROJECT_NAME}/state/${tf_env}"

FILE="terraform.tf"

export TF=$(cat <<EOF
terraform {
  backend "s3" {
    bucket = "${s3_bucket}"
    region = "${aws_default_region}"
    key    = "${s3_prefix}/${tf_env}.tfstate"
  }
}
EOF
)


if [ ! -s $FILE ]; then
  echo "Populating terraform.tf for this environment"
  echo "$TF" > $FILE
fi

terraform init -backend=true \
               -backend-config="bucket=${s3_bucket}" \
               -backend-config="key=${s3_prefix}/${tf_env}.tfstate" \
               -backend-config="region=${aws_default_region}"

 echo "set remote s3 state to ${s3_bucket}/${s3_prefix}/${tf_env}.tfstate"
# vim: set et fenc=utf-8 ff=unix sts=2 sw=2 ts=2 :
