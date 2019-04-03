data "aws_availability_zones" "available" {} #TODO: is this right?

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = "${data.consul_keys.vpc.var.id}"
}

data "aws_route53_zone" "region" {
  name = "${data.aws_region.current.name}.${var.env}.asics.digital."
}

data "aws_route53_zone" "env" {
  name = "${var.env}.asics.digital."
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = "${local.ecs_cluster_name}"
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "private"
  }
}

data "aws_subnet_ids" "database" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "database"
  }
}

data "aws_acm_certificate" "cert" {
  domain      = "${var.env}.asics.digital"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "us-east-1" {
  provider    = "aws.us-east-1"
  domain      = "${var.env}.asics.digital"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_security_group" "ecs_cluster" {
  tags {
    Name = "ecs-sg-asics-services-${var.env}-infra-svc"
  }
}

data "aws_security_group" "consul" {
  tags {
    Name = "ecs-sg-consul-${var.env}"
  }
}

data "aws_security_group" "consul_secondary" {
  tags {
    Name = "ecs-sg-consul-${var.env}-secondary"
  }
}

data "aws_caller_identity" "current" {}

data "aws_lambda_function" "logdna" {
  function_name = "LogDNA-${var.env}"
}

data "consul_keys" "vpc" {
  key {
    name = "id"
    path = "aws/vpc/VpcId"
  }
}

data "consul_keys" "app" {
  key {
    name    = "docker_image"
    path    = "${local.service_identifier}/${local.task_identifier}/docker-image"
    default = "asicsdigital/${local.service_identifier}-${local.task_identifier}:deploy-${var.env}"
  }
}

provider "vault" {
  version = "1.6.0"
  address = "${local.vault_addr}"
}

provider "consul" {
  address   = "asics-services.${data.aws_region.current.name}.${var.env}.asics.digital"
  http_auth = "${var.consul_http_auth}"
  scheme    = "https"
}
