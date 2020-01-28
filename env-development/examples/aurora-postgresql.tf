module "aurora" {
  source        = "github.com/terraform-aws-modules/terraform-aws-rds-aurora?ref=v2.15.0"
  name          = "${local.service_identifier}-${var.env}"
  database_name = local.service_identifier

  #deletion_protection             = true
  engine                          = "aurora-postgresql"
  engine_version                  = "10.5"
  vpc_id                          = data.aws_vpc.vpc.id
  subnets                         = [data.aws_subnet_ids.database.ids]
  replica_count                   = 1
  allowed_security_groups         = local.security_groups
  instance_type                   = "db.r4.large"
  storage_encrypted               = true
  apply_immediately               = false
  monitoring_interval             = 10
  backup_retention_period         = var.db_backup_retention_period
  username                        = local.service_identifier
  password                        = local.db_password
  db_parameter_group_name         = aws_db_parameter_group.app_db_aurora_parameter_grp.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.app_db_cluster_parameter_grp.name

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}

resource "aws_db_parameter_group" "app_db_aurora_parameter_grp" {
  name        = "tf-rds-${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"
  family      = var.db_family
  description = "Terraform-managed parameter group for ${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"

  tags = {
    Name = "tf-rds-${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"
  }
}

resource "aws_rds_cluster_parameter_group" "app_db_cluster_parameter_grp" {
  name        = "tf-rds-${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"
  family      = var.db_family
  description = "Terraform-managed cluster parameter group for ${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"

  tags = {
    Name = "tf-rds-${local.service_identifier}-${data.aws_vpc.vpc.tags["Name"]}"
  }
}
