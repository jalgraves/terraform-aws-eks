# terraform-aws-eks
Terraform EKS cluster module

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_identity_provider_config.okta](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) | resource |
| [aws_eks_node_group.istio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | n/a | `list` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator"<br>]</pre> | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | n/a | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | n/a | `bool` | `false` | no |
| <a name="input_istio_desired_size"></a> [istio\_desired\_size](#input\_istio\_desired\_size) | n/a | `number` | `2` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_istio_max_size"></a> [istio\_max\_size](#input\_istio\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_istio_max_unavailable"></a> [istio\_max\_unavailable](#input\_istio\_max\_unavailable) | n/a | `number` | `1` | no |
| <a name="input_istio_min_size"></a> [istio\_min\_size](#input\_istio\_min\_size) | n/a | `number` | `2` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | n/a | `string` | `"1.23"` | no |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | n/a | `number` | `2` | no |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_node_group_max_unavailable"></a> [node\_group\_max\_unavailable](#input\_node\_group\_max\_unavailable) | n/a | `number` | `1` | no |
| <a name="input_node_group_min_size"></a> [node\_group\_min\_size](#input\_node\_group\_min\_size) | n/a | `number` | `2` | no |
| <a name="input_okta_client_id"></a> [okta\_client\_id](#input\_okta\_client\_id) | n/a | `any` | `null` | no |
| <a name="input_okta_enabled"></a> [okta\_enabled](#input\_okta\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_okta_groups_claim"></a> [okta\_groups\_claim](#input\_okta\_groups\_claim) | n/a | `any` | `null` | no |
| <a name="input_okta_identity_provider_config_name"></a> [okta\_identity\_provider\_config\_name](#input\_okta\_identity\_provider\_config\_name) | n/a | `any` | `null` | no |
| <a name="input_okta_issuer_url"></a> [okta\_issuer\_url](#input\_okta\_issuer\_url) | n/a | `any` | `null` | no |
| <a name="input_okta_username_claim"></a> [okta\_username\_claim](#input\_okta\_username\_claim) | n/a | `any` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | n/a | `list` | `[]` | no |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | n/a | `string` | `"10.96.0.0/12"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_iam_openid_connect_provider_arn"></a> [iam\_openid\_connect\_provider\_arn](#output\_iam\_openid\_connect\_provider\_arn) | n/a |
| <a name="output_istio_asg_id"></a> [istio\_asg\_id](#output\_istio\_asg\_id) | n/a |
| <a name="output_kubeconfig_certificate_authority_data"></a> [kubeconfig\_certificate\_authority\_data](#output\_kubeconfig\_certificate\_authority\_data) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->
