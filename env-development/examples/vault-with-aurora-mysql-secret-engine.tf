locals {
  connection_url = "${var.db_username}:${local.db_password}@tcp(${module.aurora.writer_endpoint}:3306)/"
  vault_sql      = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';"
  vault_rw_sql   = "${local.vault_sql} GRANT SELECT,INSERT,UPDATE,DELETE ON ${var.db_name}.* TO '{{name}}'@'%';"
}

resource "vault_mount" "secret" {
  path        = "${local.service_identifier}/secret"
  type        = "kv"
  description = "KV Mount for ASICS ${local.service_identifier}"
}

data "vault_generic_secret" "app" {
  path = "${local.service_identifier}/secret/${local.task_identifier}"
}

data "vault_generic_secret" "db_password" {
  path = "${local.service_identifier}/secret/aws/rds/${var.db_name}"
}

# Allow the ECS Task to auth to vault
resource "vault_aws_auth_backend_role" "app" {
  backend   = "aws/"
  role      = "${local.service_identifier}-${local.task_identifier}"
  auth_type = "iam"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  bound_iam_principal_arns = [module.app.task_iam_role_arn]
  policies                 = [vault_policy.app.name]
  ttl                      = "86400"
}

# Policy the ECS Task gets
resource "vault_policy" "app" {
  name = "${local.service_identifier}-${local.task_identifier}"

  policy = <<EOT

path "${local.service_identifier}/secret/${local.task_identifier}" {
  policy = "read"
}

path "${local.service_identifier}/rds/creds/${local.task_identifier}" {
  policy = "read"
}
EOT

}

# Database Secret Engine
resource "vault_mount" "database" {
  path        = "${local.service_identifier}/rds"
  type        = "database"
  description = "Database Auth backend for ${local.service_identifier}"
}

resource "vault_database_secret_backend_connection" "database" {
  backend = vault_mount.database.path
  name    = var.db_name
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  allowed_roles = [local.task_identifier]

  mysql_aurora {
    connection_url = local.connection_url
  }
}

resource "vault_database_secret_backend_role" "app" {
  backend             = vault_mount.database.path
  name                = local.task_identifier
  db_name             = vault_database_secret_backend_connection.database.name
  creation_statements = local.vault_rw_sql
  default_ttl         = "86400"
}

