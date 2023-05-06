resource "aws_iam_role" "deployment_activator_exec" {
  name = "${var.identifier}-${var.environment}-deploymentActivatorExecution"
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
    name = "sqs-deployment-activator"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
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
            "ssm:GetParameter"
          ],
          "Effect" : "Allow",
          "Resource" : [aws_ssm_parameter.gitlab_deployment_hub_token.arn]
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "deployment_activator_sqs_role_policy" {
  role       = aws_iam_role.deployment_activator_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.deployment_request.arn
  function_name    = aws_lambda_function.deployment_activator.arn
}

data "archive_file" "deployment_activator" {
  type        = "zip"
  output_path = "deploymentActivator.zip"

  source {
    content  = file("../../deployment/DeploymentRequest.py")
    filename = "DeploymentRequest.py"
  }

  source {
    content  = file("../../deployment/deploymentActivator.py")
    filename = "deploymentActivator.py"
  }

  source {
    content  = file("../../deployment/InvalidGitlabResponseException.py")
    filename = "InvalidGitlabResponseException.py"
  }
}

resource "aws_lambda_function" "deployment_activator" {
  filename      = "deploymentActivator.zip"
  function_name = "${var.identifier}-${var.environment}-DeploymentActivator"
  role          = aws_iam_role.deployment_activator_exec.arn
  handler       = "deploymentActivator.lambda_handler"

  source_code_hash = data.archive_file.deployment_activator.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      identifier            = var.identifier,
      environment           = var.environment,
      gitlab_token_ssm_path = aws_ssm_parameter.gitlab_deployment_hub_token.name
    }
  }

  layers = [
    local.python_requests_layer_arn
  ]

}