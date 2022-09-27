variable "slack_token" {}

data "archive_file" "slackbot" {
  type        = "zip"
  source_dir = "../lambda/slackbot/src/"
  output_path = "../lambda/slackbot/out/slackbot.zip"
}

resource "null_resource" "make_module_layer" {
  triggers = {
    source_code_hash = filesha256("../module_layer/make_module_layer.sh")
  }
  provisioner "local-exec" {
    working_dir = "../module_layer"
    command     = "../module_layer/make_module_layer.sh"
  }
}

data "archive_file" "module_layer" {
  type        = "zip"
  source_dir  = "../module_layer/workspace/"
  output_path = "../module_layer/out/module-layer-${filesha256("../module_layer/make_module_layer.sh")}.zip"
}

resource "aws_lambda_layer_version" "module_layer" {
  layer_name = "module_layer"
  filename   = data.archive_file.module_layer.output_path
}

resource "aws_lambda_function" "slackbot" {
  role             = aws_iam_role.iam_for_lambda.arn
  function_name    = "slackbot"
  filename         = data.archive_file.slackbot.output_path
  source_code_hash = data.archive_file.slackbot.output_base64sha256
  layers = [
    "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime:1",
    resource.aws_lambda_layer_version.module_layer.arn
  ]
  handler = "main.handle"
  runtime = "provided.al2"
  environment {
    variables = {
      slack_token = var.slack_token
    }
  }
}

resource "aws_lambda_function_url" "slackbot" {
  function_name      = aws_lambda_function.slackbot.function_name
  authorization_type = "NONE"
}