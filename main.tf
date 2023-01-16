# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  role_arn                  = var.role_arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager"]
  version                   = var.kubernetes_version

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
  }

  dynamic "encryption_config" {
    for_each = var.encryption.enabled ? [var.encryption] : []

    content {
      provider {
        key_arn = aws_kms_key.this[0].arn
      }
      resources = encryption_config.value.resources
    }
  }
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.this.identity.0.oidc.0.issuer
}

resource "aws_eks_identity_provider_config" "okta" {
  count        = var.okta_enabled ? 1 : 0
  cluster_name = aws_eks_cluster.this.name

  oidc {
    client_id                     = var.okta_client_id
    identity_provider_config_name = var.okta_identity_provider_config_name
    issuer_url                    = var.okta_issuer_url
    groups_claim                  = var.okta_groups_claim
    username_claim                = var.okta_username_claim
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name      = aws_eks_cluster.this.id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.10.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "this" {
  for_each = {
    for group in var.node_groups : group.name => group
  }
  capacity_type   = each.value.capacity_type
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.name
  node_role_arn   = each.value.node_role_arn
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  subnet_ids      = var.subnet_ids
  labels = {
    role = each.value.name
  }
  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }
  update_config {
    max_unavailable = each.value.max_unavailable
  }

  dynamic "taint" {
    for_each = length(each.value.taints) > 0 ? each.value.taints : []

    content {
      effect = taint.value.effect
      key    = taint.value.key
    }
  }
  depends_on = [
    aws_eks_cluster.this
  ]
}
