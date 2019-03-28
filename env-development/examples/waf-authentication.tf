locals {
  name_alpha = "${local.service_identifier}${local.task_identifier}${var.env}"
}

resource "random_id" "x_manual_auth_secret" {
  byte_length = 32
}

resource "aws_wafregional_byte_match_set" "byte_match" {
  name = "${local.name_alpha}ByteMatch"

  byte_match_tuples {
    "field_to_match" {
      type = "HEADER"
      data = "x-manual-auth"
    }

    positional_constraint = "EXACTLY"
    text_transformation   = "NONE"
    target_string         = "${random_id.x_manual_auth_secret.b64}"
  }
}

resource "aws_wafregional_rule" "auth_rule" {
  metric_name = "${local.name_alpha}Rule"
  name        = "${local.name_alpha}Rule"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.byte_match.id}"
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_web_acl" "auth_acl" {
  "default_action" {
    type = "BLOCK"
  }

  metric_name = "${local.name_alpha}ACL"
  name        = "${local.name_alpha}ACL"

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.auth_rule.id}"
  }
}

resource "aws_wafregional_web_acl_association" "alb_association" {
  resource_arn = "${module.app.alb_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.auth_acl.id}"
}
