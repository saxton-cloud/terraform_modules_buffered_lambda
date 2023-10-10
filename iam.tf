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
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  name = "AWSLambdaVPCAccessExecutionRole"
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
  name   = "${title(var.product_code)}${title(var.qualifier)}${title(var.name)}QueueAccess"
  path   = "/${var.product_code}/${var.qualifier}/"
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
  repository = aws_ecr_repository.lambda.name
  policy     = data.aws_iam_policy_document.ecr_access.json
}
