resource "aws_cloudwatch_log_group" "lambda_logging" {
  name              = "/aws/lambda/${local.qualified_name}"
  retention_in_days = 14
  kms_key_id        = local.encryption_key.arn
}
