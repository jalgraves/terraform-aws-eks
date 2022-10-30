output "name" {
  value = aws_eks_cluster.this.name
}

output "iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}
output "istio_asg_id" {
  value = aws_eks_node_group.istio.id
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}
