# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

terraform {
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}
provider "aws" {
  region = "us-west-2"
}

module "network" {
  source  = "app.terraform.io/beantown/network/aws"
  version = "0.1.5"

  availability_zones              = ["us-west-2a", "us-west-2b"]
  create_ssh_sg                   = true
  default_security_group_deny_all = false
  environment                     = "test"
  cidr_block                      = "10.0.0.0/16"
  internet_gateway_enabled        = true
  label_create_enabled            = true
  nat_gateway_enabled             = false
  nat_instance_enabled            = false
  region_code                     = "usw2"
}

module "eks" {
  source = "../.."

  cluster_name       = "test-usw2"
  kubernetes_version = "1.23"
  subnet_ids         = module.network.private_subnet_ids[0]
}
