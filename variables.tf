# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2023

variable "cluster_name" {
  type = string
}
variable "enabled_cluster_log_types" { default = ["api", "audit", "authenticator"] }
variable "kubernetes_version" { default = "1.24" }
variable "endpoint_private_access" { default = true }
variable "endpoint_public_access" { default = false }

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

variable "okta_client_id" { default = null }
variable "okta_identity_provider_config_name" { default = null }
variable "okta_issuer_url" { default = null }
variable "okta_groups_claim" { default = null }
variable "okta_username_claim" { default = null }
variable "okta_enabled" { default = false }
variable "role_arn" {
  type = string
}
variable "security_group_ids" { default = [] }
variable "service_ipv4_cidr" { default = "10.96.0.0/12" }
variable "subnet_ids" { type = list(string) }
