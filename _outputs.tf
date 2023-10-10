
output "execution_role" {
  description = "role lambda accesses resources with"
  value       = aws_iam_role.lambda_execution
}

output "encyption_key" {
  description = "kms encryption key used to secure component elements"
  value       = local.encryption_key
}

output "input_buffer" {
  description = "sqs queue serving as the lambda's input buffer"
  value       = aws_sqs_queue.input_buffer
}

output "deadletter" {
  description = "sqs queue holding failed messages"
  value       = aws_sqs_queue.dead_letter
}
