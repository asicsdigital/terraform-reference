#!/bin/bash

FILE=foo.tf

source .env

if [ -z ${TF_PROJECT_NAME} ]; then
  echo "'TF_PROJECT_NAME' is empty, exiting with failure."
  exit 1
fi
echo $TF_PROJECT_NAME

export VARIABLES_TF=$(cat <<EOF
#  Variables.tf declares has the default variables that are shared by all environments
# \$var.region, \$var.domain, \$var.tf_s3_bucket


# Read credentials from environment variables
#$ export AWS_ACCESS_KEY_ID="anaccesskey"
#$ export AWS_SECRET_ACCESS_KEY="asecretkey"
#$ export AWS_DEFAULT_REGION="us-west-2"
#$ terraform plan
provider "aws" {
  profile = "\${var.aws_profile}"
  region  = "\${var.region}"
}

data "terraform_remote_state" "master_state" {
  backend = "s3"
  config {
    bucket = "\${var.tf_s3_bucket}"
    region = "\${var.region}"
    key    = "\${var.master_state_file}"
  }
}

variable "aws_profile" {
  description = "Which AWS profile is should be used? Defaults to \"default\""
  default     = "default"
}
variable "region" { default = "us-east-1" }


# This should be changed to reflect the service / stack defined by this repo
# for example replace "ref" with "cms", "slackbot", etc
variable "stack" { default = "ref" }

variable "tf_s3_bucket" {
  description = "S3 bucket Terraform can use for state"
  default     = "rk-devops-state-us-east-1"
}

variable "master_state_file" { default = "${TF_PROJECT_NAME}/state/base/base.tfstate" }
variable "prod_state_file" { default = "${TF_PROJECT_NAME}/state/production/production.tfstate" }
variable "staging_state_file" { default = "${TF_PROJECT_NAME}/state/staging/staging.tfstate" }
variable "dev_state_file" { default = "${TF_PROJECT_NAME}/state/dev/dev.tfstate" }

EOF
)


if [ ! -s $FILE ]; then
  echo "$VARIABLES_TF"
  echo "$VARIABLES_TF" > $FILE
fi
