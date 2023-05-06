# API Gateway
resource "aws_api_gateway_rest_api" "deployment_scheduler" {
  name        = "${var.identifier}-${var.environment}-deployment"
  description = "API for the password Manager Service"
}


###########################################
# /Deploy
###########################################
resource "aws_api_gateway_resource" "proxy_deploy" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  parent_id   = aws_api_gateway_rest_api.deployment_scheduler.root_resource_id
  path_part   = "deploy"
}

# GET
resource "aws_api_gateway_method" "request_method" {
  rest_api_id      = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id      = aws_api_gateway_resource.proxy_deploy.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.querystring.clientId"   = true,
    "method.request.querystring.templateId" = true
  }
}

resource "aws_api_gateway_integration" "request_integration" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_method.request_method.resource_id
  http_method = aws_api_gateway_method.request_method.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.deployment_orchestrator.invoke_arn

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# OPTIONS are needed for COORS
resource "aws_api_gateway_method" "options_method" {
  rest_api_id      = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id      = aws_api_gateway_resource.proxy_deploy.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_deploy.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_deploy.id
  http_method = aws_api_gateway_method.options_method.http_method

  type             = "MOCK"
  content_handling = "CONVERT_TO_TEXT"

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_deploy.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
  }

  depends_on = [
    aws_api_gateway_method_response.options_200,
    aws_api_gateway_integration.options_integration,
  ]
}


# ----------------- deployment/stage/key -------------------
resource "aws_api_gateway_stage" "deploy_scheduler" {
  deployment_id = aws_api_gateway_deployment.deploy_scheduler.id
  rest_api_id   = aws_api_gateway_rest_api.deployment_scheduler.id
  stage_name    = var.environment
}

resource "aws_api_gateway_api_key" "deploy_scheduler_key_a" {
  name = "${var.identifier}-${var.environment}-deploy-scheduler"
}

resource "aws_api_gateway_usage_plan" "deploy_scheduler_plan_a" {
  name = "${var.identifier}-${var.environment}-application"
  api_stages {
    api_id = aws_api_gateway_rest_api.deployment_scheduler.id
    stage  = aws_api_gateway_stage.deploy_scheduler.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "key_a_plan_a" {
  key_id        = aws_api_gateway_api_key.deploy_scheduler_key_a.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.deploy_scheduler_plan_a.id
}

# Deployment
resource "aws_api_gateway_deployment" "deploy_scheduler" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy_deploy.id,
      aws_api_gateway_method.request_method.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.request_integration.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}







