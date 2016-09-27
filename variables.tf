#  Variables.tf declares has the default variables that are shared by all environments
# $var.region, $var.domain, $var.tf_s3_bucket


# Read credentials from environment variables
#$ export AWS_ACCESS_KEY_ID="anaccesskey"
#$ export AWS_SECRET_ACCESS_KEY="asecretkey"
#$ export AWS_DEFAULT_REGION="us-west-2"
#$ terraform plan
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.region}"
}

data "terraform_remote_state" "master_state" {
  backend = "s3"
  config {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key    = "${var.master_state_file}"
  }
}

variable "aws_profile" {
  description = "Which AWS profile is should be used? Defaults to \"default\""
  default     = "default"
}
variable "region" { default = "us-east-1" }

variable "tf_s3_bucket" {
  description = "S3 Bucket Terraform can use for state"
  default     = "lunchbot-terraform-state"
}

variable "master_state_file" { default = "base/base.tfstate" }
variable "prod_state_file" { default = "production/production.tfstate" }
variable "staging_state_file" { default = "staging/staging.tfstate" }
variable "dev_state_file" { default = "dev/dev.tfstate" }
