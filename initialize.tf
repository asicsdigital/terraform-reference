#Initialize.tf contains empty variable declarations for the variables that will be populated in each env’s .tfvars file

variable "env" {
  type = string
}

variable "consul_http_auth" {
}

variable "fqdn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_key_name" {
  type = string
}

