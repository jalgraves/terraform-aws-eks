# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

output "name" {
  value = one(aws_eks_cluster.this[*].name)
}

output "cluster_security_group_id" {
  value = one(aws_eks_cluster.this[*].vpc_config[0].cluster_security_group_id)
}

output "iam_openid_connect_provider_arn" {
  value = one(aws_iam_openid_connect_provider.this[*].arn)
}

output "endpoint" {
  value = one(aws_eks_cluster.this[*].endpoint)
}

output "kubeconfig_certificate_authority_data" {
  value = one(aws_eks_cluster.this[*].certificate_authority[0].data)
}
