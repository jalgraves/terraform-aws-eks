# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

data "aws_partition" "current" {}

data "aws_iam_policy_document" "this" {
  count = var.encryption.enabled ? 1 : 0

  # Default policy - account wide access to all key operations
  statement {
    sid       = "Default"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Key owner - all key operations
  statement {
    sid       = "KeyOwner"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = var.encryption.owner_arns
    }
  }

  # Key administrators - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators
  statement {
    sid = "KeyAdministration"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = var.encryption.owner_arns
    }
  }

  # Key users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users
  statement {
    sid = "KeyUsage"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }

  # Key service users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration
  statement {
    sid = "KeyServiceUsage"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }

  # Key cryptographic operations - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-users-crypto
  statement {
    sid = "KeySymmetricEncryption"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }

  statement {
    sid = "KeyHMAC"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateMac",
      "kms:VerifyMac",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }

  statement {
    sid = "KeyAsymmetricPublicEncryption"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:GetPublicKey",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }

  statement {
    sid = "KeyAsymmetricSignVerify"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
      "kms:Verify",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }
}

resource "aws_kms_key" "this" {
  count = var.encryption.enabled ? 1 : 0

  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = 30
  description                        = "${var.cluster_name} KMS key. Created via Terraform."
  enable_key_rotation                = true
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy                             = data.aws_iam_policy_document.this[0].json
}

resource "aws_kms_alias" "this" {
  count = var.encryption.enabled ? 1 : 0

  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.this[0].key_id
}
