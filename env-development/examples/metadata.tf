# Add metadata to Consul
data "template_file" "terraform_version" {
  template = file(".terraform-version")
}

resource "consul_key_prefix" "terraform_app_metadata" {
  path_prefix = "${local.service_identifier}/${local.task_identifier}/metadata/"

  subkeys = {
    "version"   = trimspace(data.template_file.terraform_version.rendered)
    "last-run"  = timestamp()
    "terraform" = "true"
  }
}

