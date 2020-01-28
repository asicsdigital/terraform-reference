# Connect to Consul and Get VPC Info from the KV
data "consul_keys" "vpc" {
  key {
    name = "id"
    path = "aws/vpc/VpcId"
  }
}

