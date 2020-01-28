# For all locals that will be used in more than 1 location
locals {
  hostname           = "${var.env}.asics.digital"
  consul_addr        = "https://asics-services.us-east-1.${local.hostname}"
  vault_addr         = "https://vault.${data.aws_region.current.name}.${local.hostname}"
  ecs_cluster_name   = "asics-services-${var.env}-infra-svc"
  service_identifier = "service identifier"
  task_identifier    = "app"
  security_groups = [
    data.aws_security_group.ecs_cluster.id,
    data.aws_security_group.consul.id,
    data.aws_security_group.consul_secondary.id,
  ]
  consul_prefix = local.service_identifier
  extra_args    = "-consul-retry -consul-retry-attempts=3"
  #  db_password        = "${coalesce(var.db_password, data.vault_generic_secret.db.data["password"])}"
}

