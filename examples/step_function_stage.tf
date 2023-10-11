#
# this lambda function is used inside a step function
# it has no event_source_arn parameter and no permissions
# for accessing a queue.
#
local {
  env = "dev"
  project_name = "bayis-lambda-examples"
  lambda_source = "lambda_source_file_path.zip"
}

data "aws_iam_policy_document" "message_handler" {
}

module "message_handler" {
  source = "../."

  lambda_name      = join("-", [locals.project_name, locals.env, "message-handler"])
  lambda_filename  = locals.lambda_source
  lambda_handler   = "my_package.my_module.my_message_handler_function"
  lambda_runtime   = "python3.8"
  lambda_timeout   = 400
  lambda_memory    = 256
  lambda_env_vars  = {
    LOG_LEVEL = "DEBUG"
  }

  tags = {
    env = locals.env
    project = locals.project_name
  }

  metric_namespace = locals.project_name

  iam_policy_doc   = data.aws_iam_policy_document.message_handler.json
}
