###########################################
# /admin/deployment
###########################################

resource "aws_api_gateway_resource" "proxy_admin" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  parent_id   = aws_api_gateway_rest_api.deployment_scheduler.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "proxy_admin_deployment" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  parent_id   = aws_api_gateway_resource.proxy_admin.id
  path_part   = "deployment"
}

# POST
resource "aws_api_gateway_method" "admin_deployment_post" {
  rest_api_id      = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id      = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_deployment_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_method.admin_deployment_post.resource_id
  http_method = aws_api_gateway_method.admin_deployment_post.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.deployment_orchestrator.invoke_arn

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# PUT
resource "aws_api_gateway_method" "admin_deployment_put" {
  rest_api_id      = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id      = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_deployment_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_method.admin_deployment_put.resource_id
  http_method = aws_api_gateway_method.admin_deployment_put.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.deployment_orchestrator.invoke_arn

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# OPTIONS are needed for COORS
resource "aws_api_gateway_method" "admin_deployment_option" {
  rest_api_id      = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id      = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "admin_deployment_option_200" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method = aws_api_gateway_method.admin_deployment_option.http_method
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

  depends_on = [aws_api_gateway_method.admin_deployment_option]
}

resource "aws_api_gateway_integration" "admin_deployment_option_integration" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method = aws_api_gateway_method.admin_deployment_option.http_method

  type             = "MOCK"
  content_handling = "CONVERT_TO_TEXT"

  depends_on = [aws_api_gateway_method.admin_deployment_option]
}

resource "aws_api_gateway_integration_response" "admin_deployment_option_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.deployment_scheduler.id
  resource_id = aws_api_gateway_resource.proxy_admin_deployment.id
  http_method = aws_api_gateway_method.admin_deployment_option.http_method
  status_code = aws_api_gateway_method_response.admin_deployment_option_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
  }

  depends_on = [
    aws_api_gateway_method_response.admin_deployment_option_200,
    aws_api_gateway_integration.options_integration,
  ]
}