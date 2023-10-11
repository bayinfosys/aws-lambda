variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_filename" {
  description = "Path to the Lambda function's deployment package"
  type        = string
}

variable "lambda_handler" {
  description = "python handler for the lambda function"
  type = string
}

variable "lambda_timeout" {
  description = "lambda timeout in seconds"
  type = number
  default = 400
}

variable "lambda_memory" {
  description = "lambda memory size in mb"
  type = number
  default = 256
}

variable "lambda_runtime" {
  description = "runtime of the lambda function"
  type = string
  default = "python3.8"
}

variable "lambda_env_vars" {
  description = "environment variables for the lambda function"
  type = map
  default = {}
}

variable "tags" {
  description = "tags applied to all the resources in the module"
  type = map
  default = {}
}

variable "event_source_arn" {
  # NB: this is optional
  description = "ARN of the event source of the lambda trigger if SQS, etc"
  type = string
  default = null
}

variable "iam_policy_doc" {
  description = "aws_iam_policy document for lambda function"
  type = string
}

variable "log_retention" {
  description = "number of days to retain the logs for this lambda"
  type = number
  default = 14
}

variable "metric_namespace" {
  description = "the namespace with which to associate error metrics"
  type = string
}
