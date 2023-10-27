resource "aws_lambda_function" "this" {
  function_name = local.qualified_name
  description   = coalesce(var.description, "${var.subsystem} component")
  role          = aws_iam_role.lambda_execution.arn
  memory_size   = var.memory_size
  timeout       = var.timeout
  package_type  = "Image"
  image_uri     = "${local.repository_url}:${var.revision}"

  dynamic "image_config" {
    for_each = var.image_config == null ? [] : [1]
    content {
      command           = var.image_config.command
      entry_point       = var.image_config.entry_point
      working_directory = var.image_config.working_directory
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  environment {
    variables = merge({
      INPUT_BUFFER_URI = aws_sqs_queue.input_buffer.url,
      DEADLETTER_URI   = aws_sqs_queue.dead_letter.url
      REVISION         = var.revision
    }, var.environment)
  }
}

resource "aws_lambda_event_source_mapping" "input_buffer" {
  event_source_arn        = aws_sqs_queue.input_buffer.arn
  function_name           = aws_lambda_function.this.arn
  batch_size              = var.batch_size
  function_response_types = var.checkpoint_support ? ["ReportBatchItemFailures"] : null
  scaling_config {
    maximum_concurrency = var.maximum_concurrency
  }
}
