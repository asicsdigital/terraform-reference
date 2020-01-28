# This examples assumes that you have the vault provider configured
# Usage : https://github.com/russellcardullo/terraform-provider-pingdom/blob/master/README.md#usage

provider "pingdom" {
  user          = data.vault_generic_secret.pingdom.data["user"]
  password      = data.vault_generic_secret.pingdom.data["password"]
  api_key       = data.vault_generic_secret.pingdom.data["apikey"]
  account_email = data.vault_generic_secret.pingdom.data["account_email"] # Optional: only required for multi-user accounts
}

resource "pingdom_check" "example" {
  type       = "http"
  name       = "my http check"
  host       = "google.com"
  resolution = 5
}
