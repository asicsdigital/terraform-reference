data "terraform_remote_state" "staging_state" {
  backend = "s3"
  config {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key    = "${var.staging_state_file}"
  }
}
