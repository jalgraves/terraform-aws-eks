# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "this" {
  count                     = var.enabled ? 1 : 0
  name                      = var.cluster_name
  role_arn                  = var.role_arn
  enabled_cluster_log_types = var.enabled_cluster_log_types
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
  count = var.enabled ? 1 : 0
  url   = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.enabled ? 1 : 0
  client_id_list  = var.client_id_list
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_eks_identity_provider_config" "oidc" {
  count        = var.enabled && var.oidc_enabled ? 1 : 0
  cluster_name = aws_eks_cluster.this[0].name

  oidc {
    client_id                     = var.oidc_client_id
    identity_provider_config_name = var.oidc_identity_provider_config_name
    issuer_url                    = var.oidc_issuer_url
    groups_claim                  = var.oidc_groups_claim
    username_claim                = var.oidc_username_claim
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count             = var.enabled && var.addons.aws_ebs_csi_driver.enabled ? 1 : 0
  cluster_name      = aws_eks_cluster.this[0].id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = var.addons.aws_ebs_csi_driver.version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  count             = var.enabled && var.addons.coredns.enabled ? 1 : 0
  cluster_name      = aws_eks_cluster.this.id
  addon_name        = "coredns"
  addon_version     = var.addons.coredns.version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  count             = var.enabled && var.addons.vpc_cni.enabled ? 1 : 0
  cluster_name      = aws_eks_cluster.this.id
  addon_name        = "vpc-cni"
  addon_version     = var.addons.vpc_cni.version
  resolve_conflicts = "OVERWRITE"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  count = var.enabled ? 1 : 0
  name  = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this[0].version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "this" {
  for_each = {
    for group in var.node_groups : group.name => group
    if var.enabled
  }
  capacity_type   = each.value.capacity_type
  cluster_name    = aws_eks_cluster.this[0].name
  node_group_name = each.value.name
  node_role_arn   = each.value.node_role_arn
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version[0].value)
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
