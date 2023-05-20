data "archive_file" "post_deployment_processor" {
  type        = "zip"
  output_path = "postDeploymentProcessor.zip"

  source {
    content  = file("../../deployment/postDeploymentProcessor.py")
    filename = "postDeploymentProcessor.py"
  }

  source {
    content  = file("../../deployment/commons.py")
    filename = "commons.py"
  }
}

resource "aws_lambda_function" "post_deployment" {
  filename      = "postDeploymentProcessor.zip"
  function_name = local.post_deployment_processor_function_name
  role          = aws_iam_role.post_deployment_exec.arn
  handler       = "postDeploymentProcessor.lambda_handler"

  source_code_hash = data.archive_file.post_deployment_processor.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DEPLOYMENT_REQUEST_QUEUE_NAME = aws_sqs_queue.deployment_request.name
      ENVIRONMENT                   = var.environment
    }
  }

  layers = [
    local.lambda_powertools_arn
  ]
}

resource "aws_cloudwatch_log_group" "post_deployment_processor" {
  name              = "/aws/lambda/${local.post_deployment_processor_function_name}"
  retention_in_days = 7
}

resource "aws_sns_topic_subscription" "post_deploy_event" {
  topic_arn = aws_sns_topic.post_deployment_events.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.post_deployment.arn
}

resource "aws_lambda_permission" "post_deployment_sns" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_deployment.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.post_deployment_events.arn
}

resource "aws_iam_role" "post_deployment_exec" {
  name = "${var.identifier}-${var.environment}-postDeploymentProcessor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "post-deployment-event"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sns:Publish"
          ],
          "Effect" : "Allow",
          "Resource" : [
            aws_sns_topic.post_deployment_events.arn
          ]
        },
        {
          "Action" : [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : ["${aws_cloudwatch_log_group.post_deployment_processor.arn}:*"]
        },
        {
          "Action" : [
            "dynamodb:*"
          ],
          "Effect" : "Allow",
          "Resource" : [
            aws_dynamodb_table.deployment_history.arn,
          ]
        }
      ]
    })
  }
}