resource "aws_ecr_repository" "lambda" {
  name                 = local.qualified_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = local.encryption_key.arn
  }

}


resource "aws_lambda_function" "this" {
  function_name = local.qualified_name
  role          = aws_iam_role.lambda_execution.arn
  memory_size   = 512
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.revision}"
  environment {
    variables = merge({
      INPUT_BUFFER_URI = aws_sqs_queue.input_buffer.url,
      DEADLETTER_URI   = aws_sqs_queue.dead_letter.url
      REVISION         = var.revision
    }, var.environment)
  }
}

resource "aws_lambda_event_source_mapping" "input_buffer" {
  event_source_arn = aws_sqs_queue.input_buffer.arn
  function_name    = aws_lambda_function.this.arn
  scaling_config {
    maximum_concurrency = var.maximum_concurrency
  }
}
