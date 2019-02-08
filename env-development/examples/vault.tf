# Vault Example - Get Pingdom secrets from Vault
provider "vault" {
  version = "1.1.0"
  address = "${local.vault_addr}"
}

data "vault_generic_secret" "pingdom" {
  path = "secret/pingdom"
}
