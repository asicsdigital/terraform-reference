# This module will depend on a couple of inputs
# vpc_id, subnet_id
# Read credentials from environment variables
#$ export AWS_ACCESS_KEY_ID="anaccesskey"
#$ export AWS_SECRET_ACCESS_KEY="asecretkey"
#$ export AWS_DEFAULT_REGION="us-west-2"

module "ecs-cluster" {
  source       = "./terraform-ecs-cluster"
  name         = "infra-services"
  servers      = 1
  subnet_id    = "subnet-6e101446"
  vpc_id       = "vpc-99e73dfc"
  #ami = { us-east-1 = "ami-6869aa05" }
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
