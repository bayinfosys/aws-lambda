output "lambda_arn" {
  description = "ARN of the lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_alias_arn" {
  description = "ARN of the lambda alias to accomodate CI"
  value = aws_lambda_alias.this.invoke_arn
}

output "alerts_topic_arn" {
  description = "ARN of the error topic from the alerts"
  value = aws_sns_topic.alerts.arn

  # e.g., use as:
  #resource "aws_sns_topic_subscription" "lambda_error_email_alert" {
  #  topic_arn = aws_sns_topic.alerts.arn
  #  protocol  = "email"
  #  endpoint  = "support@popstory.co.uk"
  #}
}

output "execution_role_arn" {
  description = "ARN of the lambda execution role"
  value = aws_iam_role.this.arn
}
