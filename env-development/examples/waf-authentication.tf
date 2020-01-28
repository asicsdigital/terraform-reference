locals {
  name_alpha = "${local.service_identifier}${local.task_identifier}${var.env}"
}

module "waf_auth" {
  source         = "github.com/asicsdigital/terraform-aws-alb-waf-auth?ref=v1.0.0"
  alb_arn        = module.app.alb_arn
  waf_name_alpha = local.name_alpha
}

output "x_manual_auth_secret" {
  value = module.waf_auth.x_manual_auth_target_string
}
