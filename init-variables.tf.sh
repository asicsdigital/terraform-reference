#!/bin/bash

FILE=variables.tf

source .env
aws_default_region="${AWS_DEFAULT_REGION:-us-east-1}"

if [ -z ${TF_PROJECT_NAME} ]; then
  echo "'TF_PROJECT_NAME' is empty, exiting with failure."
  exit 1
fi
echo $TF_PROJECT_NAME

tf_spine="${TF_SPINE:-rk}"

# Set stack if TF_STACK is set; if not, comment out the stack variable entirely
if [[ "${TF_STACK}" ]] ; then
  STACK_VAR_COMMENT_OPTIONAL=""
  STACK_VAR_DEFAULT="$TF_STACK"
else
  STACK_VAR_COMMENT_OPTIONAL="# "
  STACK_VAR_DEFAULT="ref"
fi

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
  version = "1.29.0"
}

provider "aws" {
  profile = "\${var.aws_profile}"
  region  = "us-east-1"
  alias   = "us-east-1"
  version = "1.29.0"
}

provider "aws" {
  profile = "\${var.aws_profile}"
  region  = "us-west-1"
  alias   = "us-west-1"
  version = "1.29.0"
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
variable "region" { default = "${aws_default_region}" }


# This should be changed to reflect the service / stack defined by this repo
# for example replace "ref" with "cms", "slackbot", etc
${STACK_VAR_COMMENT_OPTIONAL}variable "stack" { default = "${STACK_VAR_DEFAULT}" }

variable "tf_s3_bucket" {
  description = "S3 bucket Terraform can use for state"
  default     = "${tf_spine}-devops-state-${aws_default_region}"
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
