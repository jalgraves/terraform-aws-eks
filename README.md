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
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.eks_ami_release_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | n/a | `list` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator"<br>]</pre> | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | n/a | <pre>object({<br>    enabled    = bool<br>    owner_arns = list(string)<br>    resources  = list(string)<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "owner_arns": [],<br>  "resources": [<br>    "secrets"<br>  ]<br>}</pre> | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | n/a | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | n/a | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | n/a | `string` | `"1.24"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | n/a | <pre>list(object({<br>    capacity_type   = string<br>    instance_types  = list(string)<br>    name            = string<br>    node_role_arn   = string<br>    desired_size    = number<br>    max_size        = number<br>    min_size        = number<br>    max_unavailable = number<br>    taints = list(object({<br>      effect = string<br>      key    = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_okta_client_id"></a> [okta\_client\_id](#input\_okta\_client\_id) | n/a | `any` | `null` | no |
| <a name="input_okta_enabled"></a> [okta\_enabled](#input\_okta\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_okta_groups_claim"></a> [okta\_groups\_claim](#input\_okta\_groups\_claim) | n/a | `any` | `null` | no |
| <a name="input_okta_identity_provider_config_name"></a> [okta\_identity\_provider\_config\_name](#input\_okta\_identity\_provider\_config\_name) | n/a | `any` | `null` | no |
| <a name="input_okta_issuer_url"></a> [okta\_issuer\_url](#input\_okta\_issuer\_url) | n/a | `any` | `null` | no |
| <a name="input_okta_username_claim"></a> [okta\_username\_claim](#input\_okta\_username\_claim) | n/a | `any` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | n/a | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | n/a | `list` | `[]` | no |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | n/a | `string` | `"10.96.0.0/12"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_iam_openid_connect_provider_arn"></a> [iam\_openid\_connect\_provider\_arn](#output\_iam\_openid\_connect\_provider\_arn) | n/a |
| <a name="output_kubeconfig_certificate_authority_data"></a> [kubeconfig\_certificate\_authority\_data](#output\_kubeconfig\_certificate\_authority\_data) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->
