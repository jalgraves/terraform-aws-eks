# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

terraform {
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
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

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks" {
  name               = "TestUsw2EKSCluster"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

locals {
  node_groups = [
    {
      capacity_type   = "SPOT"
      instance_types  = ["t3a.medium", "t3a.large"]
      name            = "tainted-nodes"
      node_role_arn   = aws_iam_role.eks.arn
      desired_size    = 1
      max_size        = 2
      min_size        = 0
      max_unavailable = 1
      taints = [
        {
          effect = "NO_SCHEDULE"
          key    = "node-role/example"
        }
      ]
    },
    {
      capacity_type   = "SPOT"
      instance_types  = ["t3a.medium", "t3a.large"]
      name            = "untainted-nodes"
      node_role_arn   = aws_iam_role.eks.arn
      desired_size    = 1
      max_size        = 2
      min_size        = 0
      max_unavailable = 1
      taints          = []
    }
  ]
}

module "eks" {
  source = "../.."

  cluster_name       = "test-usw2-01"
  kubernetes_version = "1.24"
  role_arn           = aws_iam_role.eks.arn
  subnet_ids         = [module.network.private_subnet_ids[0]]
  node_groups        = local.node_groups
}
