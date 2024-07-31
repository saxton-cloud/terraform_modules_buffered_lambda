locals {
  encryption_key = var.kms_key != null ? var.kms_key : aws_kms_key.encryption[0]
}

resource "aws_kms_key" "encryption" {
  count                   = var.kms_key == null ? 1 : 0
  description             = "dedicated key used by '${local.qualified_name}' elements"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
resource "aws_kms_alias" "encryption" {
  count         = var.kms_key == null ? 1 : 0
  name          = "alias/${var.product_code}/${var.qualifier}/${var.subsystem}/${var.name}"
  target_key_id = aws_kms_key.encryption[0].key_id
}

resource "aws_kms_key_policy" "custom" {
  count  = var.kms_key == null ? 1 : 0
  key_id = aws_kms_key.encryption[0].id
  policy = jsonencode({
    Id      = "custom"
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Permit CloudWatch usage"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${local.region}:${local.account_id}:*"
          }
        }
      }
    ]
  })
}
