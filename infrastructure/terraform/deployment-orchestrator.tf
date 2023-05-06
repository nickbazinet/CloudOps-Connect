resource "aws_iam_role" "deployment_orchestrator_exec" {
  name = "${var.identifier}-${var.environment}-deploymentOrchestratorExecution"
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
    name = "sqs-deployment-request"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sqs:SendMessage",
            "sqs:GetQueueUrl",
            "sqs:ListQueues",
            "sqs:GetQueueAttributes"
          ],
          "Effect" : "Allow",
          "Resource" : [
            aws_sqs_queue.deployment_request.arn
          ]
        },
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : ["*"]
        },
        {
          "Action" : [
            "dynamodb:*"
          ],
          "Effect" : "Allow",
          "Resource" : [
            aws_dynamodb_table.client_configs.arn,
            aws_dynamodb_table.client_deployment_template_configs.arn,
            aws_dynamodb_table.deployment_history.arn,
            aws_dynamodb_table.deployment_template_configs.arn
          ]
        }
      ]
    })
  }
}

data "archive_file" "deployment_orchestrator" {
  type        = "zip"
  output_path = "deploymentOrchestrator.zip"

  source {
    content  = file("../../deployment/DeploymentRequest.py")
    filename = "DeploymentRequest.py"
  }

  source {
    content  = file("../../deployment/deploymentOrchestrator.py")
    filename = "deploymentOrchestrator.py"
  }
}

resource "aws_lambda_function" "deployment_orchestrator" {
  filename      = "deploymentOrchestrator.zip"
  function_name = "${var.identifier}-${var.environment}-DeploymentOrchestrator"
  role          = aws_iam_role.deployment_orchestrator_exec.arn
  handler       = "deploymentOrchestrator.lambda_handler"

  source_code_hash = data.archive_file.deployment_activator.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DEPLOYMENT_REQUEST_QUEUE_NAME = aws_sqs_queue.deployment_request.name
      ENVIRONMENT                   = var.environment
    }
  }
}

resource "aws_lambda_permission" "apigw_orchestrator" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deployment_orchestrator.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.deployment_scheduler.execution_arn}/*/*/*"
}