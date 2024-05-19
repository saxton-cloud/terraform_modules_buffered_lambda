resource "aws_sqs_queue" "input_buffer" {
  name                              = "${local.qualified_name}-buffer"
  message_retention_seconds         = 1209600
  kms_master_key_id                 = local.encryption_key.key_id
  kms_data_key_reuse_period_seconds = 86400
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 4
  })
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
  visibility_timeout_seconds = (6 * var.timeout) + var.max_batch_window_seconds
}

resource "aws_sqs_queue" "dead_letter" {
  name                              = "${local.qualified_name}-deadletter"
  message_retention_seconds         = 1209600
  kms_master_key_id                 = local.encryption_key.key_id
  kms_data_key_reuse_period_seconds = 86400
}
