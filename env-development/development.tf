data "terraform_remote_state" "dev_state" {
  backend = "s3"
  config {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key    = "${var.master_state_file}"
  }
}


# This module will depend on a couple of inputs
# vpc_id, subnet_id
# Read credentials from environment variables
#$ export AWS_ACCESS_KEY_ID="anaccesskey"
#$ export AWS_SECRET_ACCESS_KEY="asecretkey"
#$ export AWS_DEFAULT_REGION="us-west-2"

module "vpc" {
  source             = "github.com/terraform-community-modules/tf_aws_vpc"
  name               = "tf-lunchbot-vpc"
  enable_dns_support = true
  cidr               = "10.0.0.0/16"
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24" ]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24" ]
  azs                = ["us-east-1b", "us-east-1c"]
}

module "ecs-cluster" {
  source       = "github.com/tfhartmann/tf-aws-ecs"
  name         = "infra-svc-lunchbot"
  servers      = 1
  subnet_id    = "${element(module.vpc.public_subnets, 0)}"
  vpc_id       = "${module.vpc.vpc_id}"
  key_name     = "${var.aws_key_name}"
}

resource "aws_ecs_task_definition" "ecs-lunchbot" {
  family                = "ecs-lunchbot"
  container_definitions = "${template_file.lunchbot-container.rendered}"
}

resource "template_file" "lunchbot-container" {
  template = "${file("lunchbot.json")}"
  vars {
    slack_url = "${var.slack_url}"
  }
}

resource "aws_ecs_service" "slack_lunchbot" {
  name            = "slack_lunchbot"
  cluster         = "${module.ecs-cluster.cluster_id}"
  task_definition = "${aws_ecs_task_definition.ecs-lunchbot.arn}"
  desired_count   = 1
  #depends_on = ["aws_iam_instance_profile.ecs_test_profile"]
}
