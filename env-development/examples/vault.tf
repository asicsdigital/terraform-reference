# Vault Example - Get Pingdom secrets from Vault

data "vault_generic_secret" "pingdom" {
  path = "secret/pingdom"
}

