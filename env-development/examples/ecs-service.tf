# app.tf

variable "app_port" {
  description = "Port on which application listens (default 80)"
  default     = 80
}

variable "api_docker_image" {
  description = "Docker image to pull for api ECS task"
  default     = ""
}

variable "docker_memory" {
  default     = "512"
  description = "Max Memory reservation for ECS Task"
}

variable "docker_memory_reservation" {
  default     = "128"
  description = "Min Memory reservation for ECS Task"
}

variable "ecs_desired_count" {
  default     = "1"
  description = "Desired count of ECS Tasks running"
}

module "app" {
  source                    = "github.com/FitnessKeeper/terraform-aws-ecs-service?ref=v4.0.3"
  region                    = data.aws_region.current.name
  vpc_id                    = data.aws_vpc.vpc.id
  ecs_security_group_id     = data.aws_security_group.ecs_cluster.id
  ecs_cluster_arn           = data.aws_ecs_cluster.ecs.arn
  service_identifier        = "${local.service_identifier}-${var.env}"
  task_identifier           = local.task_identifier
  docker_image              = data.consul_keys.app.var.docker_image
  app_port                  = var.app_port
  acm_cert_domain           = "${var.env}.asics.digital"
  alb_subnet_ids            = [data.aws_subnet_ids.public.ids]
  alb_healthcheck_path      = local.healthcheck_path
  lb_bucket_name            = "asics-devops-${data.aws_region.current.name}"
  alb_healthcheck_interval  = 10
  ecs_desired_count         = var.ecs_desired_count
  docker_memory             = var.docker_memory
  docker_memory_reservation = var.docker_memory_reservation

  docker_port_mappings = [
    {
      "containerPort" = var.app_port
    },
  ]

  docker_environment = [
    {
      "name"  = "CONSUL_PREFIX"
      "value" = local.consul_prefix
    },
    {
      "name"  = "EXTRA_ARGS"
      "value" = local.extra_args
    },
    {
      "name"  = "VAULT_ROLE"
      "value" = "${local.service_identifier}-${local.task_identifier}"
    },
    {
      "name"  = "DB_HOST"
      "value" = module.aurora.this_rds_cluster_endpoint
    },
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "logdna_lambdafunction_logfilter" {
  name            = "${local.service_identifier}_${local.task_identifier}_${var.env}_filter"
  log_group_name  = "${local.service_identifier}-${var.env}-${local.task_identifier}"
  filter_pattern  = ""
  destination_arn = replace(data.aws_lambda_function.logdna.arn, ":$LATEST", "")
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "${local.service_identifier}-${var.env}-${local.task_identifier}-AllowExecutionFromCloudWatch-${data.aws_lambda_function.logdna.function_name}-${data.aws_region.current.name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.logdna.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.service_identifier}-${var.env}-${local.task_identifier}:*"
}
