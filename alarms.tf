# https://docs.aws.amazon.com/lambda/latest/dg/monitoring-functions.html
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.qualified_name}_lambda_Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function errors"

  dimensions = {
    FunctionName = local.qualified_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.qualified_name}_lambda_Throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function throttles"

  dimensions = {
    FunctionName = local.qualified_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_deadletter_messages_visible" {
  alarm_name          = "${local.qualified_name}_sqs_dlq_ApproximateNumberOfMessagesVisible"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "One or more message(s) found in the function's dead-letter queue"

  dimensions = {
    QueueName = aws_sqs_queue.dead_letter.name
  }
}


resource "aws_cloudwatch_metric_alarm" "sqs_buffer_messages_retention_threshold_nearing" {
  alarm_name          = "${local.qualified_name}_sqs_buffer_retention_threshold_nearing"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = aws_sqs_queue.input_buffer.message_retention_seconds * 0.8
  alarm_description   = "Indicates messages are reaching the queue's retention threshold and risk being dropped/lost without intervention"

  dimensions = {
    QueueName = aws_sqs_queue.input_buffer.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages_retention_threshold_nearing" {
  alarm_name          = "${local.qualified_name}_sqs_dlq_retention_threshold_nearing"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = aws_sqs_queue.dead_letter.message_retention_seconds * 0.8
  alarm_description   = "Indicates messages are reaching the queue's retention threshold and risk being dropped/lost without intervention"

  dimensions = {
    QueueName = aws_sqs_queue.dead_letter.name
  }
}
