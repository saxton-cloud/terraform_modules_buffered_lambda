locals {
  policy_name_prefix = replace("${title(var.product_code)}${title(var.qualifier)}${title(var.name)}", "[\\-_]", "")
  policy_path        = "/${var.product_code}/${var.qualifier}/"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = "${local.qualified_name}-exec"
  description        = "roles used by lambda when accessing resources"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  name = "AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}


data "aws_iam_policy_document" "input_buffer_access" {
  statement {
    sid = "InputBufferAccess"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.input_buffer.arn
    ]
  }
  statement {
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [local.encryption_key.arn]
  }
}

resource "aws_iam_policy" "input_buffer_access" {
  name   = "${local.policy_name_prefix}QueueAccess"
  path   = local.policy_path
  policy = data.aws_iam_policy_document.input_buffer_access.json
}

resource "aws_iam_role_policy_attachment" "input_buffer_access" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.input_buffer_access.arn
}


data "aws_iam_policy_document" "ecr_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer"]
  }
}

resource "aws_ecr_repository_policy" "ecr_access" {
  count      = local.repository_provided ? 0 : 1
  repository = aws_ecr_repository.dedicated[0].name
  policy     = data.aws_iam_policy_document.ecr_access.json
}

resource "aws_iam_policy" "ssm_access" {
  name        = "${local.policy_name_prefix}SsmAccess"
  description = "allows access to any SSM parameters under the component's path"
  path        = local.policy_path
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowedComponentScopedSsmRead"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:*:${local.account_id}:parameter:${var.product_code}/${var.qualifier}/${var.subsystem}/${var.name}/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_access" {
  policy_arn = aws_iam_policy.ssm_access.arn
  role       = aws_iam_role.lambda_execution.name
}

resource "aws_iam_role_policy_attachment" "aws_lambda_vpc_access_execution" {
  count      = var.vpc_config != null ? 1 : 0
  policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
  role       = aws_iam_role.lambda_execution.name
}
