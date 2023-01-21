# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

variable "addons" {
  default = {
    aws_ebs_csi_driver = {
      enabled = true
      version = "v1.14.1-eksbuild.1"
    }
    coredns = {
      enabled = false
      version = "v1.8.7-eksbuild.3"
    }
    vpc_cni = {
      enabled = false
      version = "v1.11.4-eksbuild.1"
    }
  }
}

variable "client_id_list" {
  type    = list(string)
  default = ["sts.amazonaws.com"]
}
variable "cluster_name" {
  type = string
}
variable "encryption" {
  type = object({
    enabled    = bool
    owner_arns = list(string)
    resources  = list(string)
  })
  default = {
    enabled    = false
    resources  = ["secrets"]
    owner_arns = []
  }
}
variable "enabled" {
  type    = bool
  default = true
}
variable "enabled_cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator"]
}
variable "endpoint_private_access" {
  type    = bool
  default = true
}
variable "endpoint_public_access" {
  type    = bool
  default = false
}
variable "kubernetes_version" {
  type    = string
  default = "1.24"
}
variable "node_groups" {
  type = list(object({
    capacity_type   = string
    instance_types  = list(string)
    name            = string
    node_role_arn   = string
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
    taints = list(object({
      effect = string
      key    = string
    }))
  }))
  default = []
}
variable "oidc_client_id" {
  type    = string
  default = null
}
variable "oidc_identity_provider_config_name" {
  type    = string
  default = null
}
variable "oidc_issuer_url" {
  type    = string
  default = null
}
variable "oidc_groups_claim" {
  type    = string
  default = null
}
variable "oidc_username_claim" {
  type    = string
  default = null
}
variable "oidc_enabled" {
  type    = bool
  default = false
}
variable "role_arn" {
  type = string
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "service_ipv4_cidr" {
  type    = string
  default = "10.96.0.0/12"
}
variable "subnet_ids" {
  type = list(string)
}
