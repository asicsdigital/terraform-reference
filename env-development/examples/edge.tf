# edge.tf

resource "aws_route53_record" "app_env_cname" {
  zone_id = "${data.aws_route53_zone.env.zone_id}"
  name    = "${local.service_identifier}-${local.task_identifier}.${var.env}.asics.digital"
  type    = "CNAME"
  ttl     = "60"

  weighted_routing_policy {
    weight = 100
  }

  set_identifier = "${data.aws_region.current.name}"

  records = ["${aws_route53_record.app_a.name}"]
}

resource "aws_route53_record" "app_a" {
  zone_id = "${data.aws_route53_zone.region.zone_id}"
  name    = "${local.service_identifier}-${local.task_identifier}.${data.aws_region.current.name}.${var.env}.asics.digital"
  type    = "A"

  alias {
    name                   = "${module.app.alb_dns_name}"
    zone_id                = "${module.app.alb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_aaaa" {
  zone_id = "${data.aws_route53_zone.region.zone_id}"
  name    = "${local.service_identifier}-${local.task_identifier}.${data.aws_region.current.name}.${var.env}.asics.digital"
  type    = "AAAA"

  alias {
    name                   = "${module.app.alb_dns_name}"
    zone_id                = "${module.app.alb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_origin_access_identity" "static" {
  comment = "CloudFront access to S3 bucket as.${var.env}.asics.digital"
}
