provider "vault" {
  version = "~> 2.0"
  address = local.vault_addr
}

provider "consul" {
  address   = "asics-services.${data.aws_region.current.name}.${var.env}.asics.digital"
  http_auth = var.consul_http_auth
  scheme    = "https"
}

