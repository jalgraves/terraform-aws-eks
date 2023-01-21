# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

terraform {
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}


locals {
  availability_zones = ["us-east-1a", "us-east-1b"]
  cidr_block         = "10.20.0.0/16"
  env                = "test"
  kubernetes_version = "1.24"
  region             = "us-east-1"
  region_code        = "use1"
  public_subnet_tags = {
    "cpco.io/subnet/type"                                     = "public"
    "kubernetes.io/cluster/${local.env}-${local.region_code}" = "owned"
    "kubernetes.io/role/elb"                                  = "1"
    "Name"                                                    = "${local.env}-public-${local.region_code}"
  }
  private_subnet_tags = {
    "cpco.io/subnet/type"                                     = "private"
    "kubernetes.io/cluster/${local.env}-${local.region_code}" = "owned"
    "kubernetes.io/role/internal-elb"                         = "1"
  }
}

provider "aws" {
  region = local.region
}

module "network" {
  source  = "app.terraform.io/beantown/network/aws"
  version = "0.1.8"

  availability_zones              = local.availability_zones
  env                             = local.env
  cidr_block                      = local.cidr_block
  private_subnets_additional_tags = local.private_subnet_tags
  public_subnets_additional_tags  = local.public_subnet_tags
  vpc_name                        = "${local.env}-${local.region_code}"
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
  name               = "${title(local.env)}${title(local.region_code)}EKSCluster"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

locals {
  addons = {
    aws_ebs_csi_driver = {
      enabled = false
    }
  }
  node_groups = [
    {
      capacity_type   = "SPOT"
      instance_types  = ["t2.medium", "t3a.medium", "t3a.large"]
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
      instance_types  = ["t2.medium", "t3a.medium", "t3a.large"]
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

  addons                    = local.addons
  cluster_name              = "${local.env}-${local.region_code}-01"
  enabled                   = true
  enabled_cluster_log_types = []
  kubernetes_version        = local.kubernetes_version
  role_arn                  = aws_iam_role.eks.arn
  subnet_ids                = module.network.subnets.private_subnet_ids
  node_groups               = local.node_groups
}

module "eks_disabled" {
  source = "../.."

  cluster_name       = "${local.env}-${local.region_code}-02"
  enabled            = false
  kubernetes_version = local.kubernetes_version
  role_arn           = aws_iam_role.eks.arn
  subnet_ids         = module.network.subnets.private_subnet_ids
  node_groups        = local.node_groups
}

output "endpoint" {
  value = module.eks.endpoint
}
output "endpoint_disabled" {
  value = module.eks_disabled.endpoint
}

output "sg_id" {
  value = module.eks_disabled.cluster_security_group_id
}
