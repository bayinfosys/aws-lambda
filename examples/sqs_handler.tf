#
# lambda function to process messages from an event queue
#
local {
  env = "dev"
  project_name = "bayis-lambda-examples"
  lambda_source = "lambda_source_file_path.zip"
}

data "aws_iam_policy_document" "message_handler" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
    ]
    resources = [
      aws_sqs_queue.my_queue.arn
    ]
  }
}

module "message_handler" {
  source = "../."

  event_source_arn = aws_sqs_queue.my_queues.arn

  lambda_name      = join("-", [locals.project_name, locals.env, "message-handler"])
  lambda_filename  = locals.lambda_source
  lambda_handler   = "my_package.my_module.my_message_handler_function"
  lambda_runtime   = "python3.8"
  lambda_timeout   = 400
  lambda_memory    = 1024

  lambda_env_vars  = {
      MY_API_KEY           = "xxx"
  }

  tags = {
    env = locals.env
    project = locals.project_name
  }

  metric_namespace = locals.project_name

  iam_policy_doc   = data.aws_iam_policy_document.message_handler.json
}
