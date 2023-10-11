#
# CODE
#
resource "aws_lambda_function" "this" {
  filename = var.lambda_filename
  function_name = var.lambda_name
  role = aws_iam_role.this.arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime

  timeout = var.lambda_timeout
  memory_size = var.lambda_memory

  source_code_hash = filebase64sha256(var.lambda_filename)

  environment { variables = var.lambda_env_vars }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "this" {
  count = var.event_source_arn != null ? 1 : 0

  event_source_arn = var.event_source_arn
  function_name    = aws_lambda_function.this.arn
}

resource "aws_lambda_alias" "this" {
  name             = join("-", [aws_lambda_function.this.function_name, "alias"])
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

#
# LOGS/ALERTS
#
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention
  tags = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  name           = "error-filter-${var.lambda_name}"
  # NB: this pattern is for unstructured logs
  pattern = "\"[ERROR]\" ? \"[CRITICAL]\" ? \"[WARNING]\""
  # for structured logs use this pattern:
  #pattern        = "{ $.severity = \"ERROR\" || $.severity = \"CRITICAL\" || $.severity = \"WARNING\" }"
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name      = "errorCount"
    namespace = var.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "LambdaErrorAlarm-${var.lambda_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.this.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.this.metric_transformation[0].namespace
  period              = "300"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "Triggered when there's an error, critical, or warning in the Lambda logs for ${var.lambda_name}."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LogGroupName = var.lambda_name
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.lambda_name}-alerts"
}

#
# IAMs
#
resource "aws_iam_policy" "this" {
  # TODO: do not create this resource if var.iam_policy is null
  name = "${var.lambda_name}-policy"
  policy = var.iam_policy_doc
  tags = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  # NB: we only need this is var.iam_policy is not null
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
