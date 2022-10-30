# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

resource "aws_eks_cluster" "this" {
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
  cluster_name = aws_eks_cluster.main.name

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

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  subnet_ids      = var.subnet_ids
  labels = {
    role = "worker"
  }
  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }
  update_config {
    max_unavailable = var.node_group_max_unavailable
  }
  depends_on = [
    aws_eks_cluster.this
  ]
}

resource "aws_eks_node_group" "istio" {
  count           = var.istio_enabled ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "istio"
  node_role_arn   = var.role_arn
  subnet_ids      = var.subnet_ids
  labels = {
    role = "istio"
  }

  scaling_config {
    desired_size = var.istio_desired_size
    max_size     = var.istio_max_size
    min_size     = var.istio_min_size
  }

  update_config {
    max_unavailable = var.istio_max_unavailable
  }

  taint {
    effect = "NO_SCHEDULE"
    key    = "node-role/istio"
  }
}
