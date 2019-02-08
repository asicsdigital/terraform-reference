# Connect to Consul and Get VPC Info from the KV

provider "consul" {
  address   = "asics-services.${data.aws_region.current.name}.${var.env}.asics.digital"
  http_auth = "${var.consul_http_auth}"
  scheme    = "https"
}

data "consul_keys" "vpc" {
  key {
    name = "id"
    path = "aws/vpc/VpcId"
  }
}
