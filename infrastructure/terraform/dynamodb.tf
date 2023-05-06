resource "aws_dynamodb_table" "deployment_template_configs" {
  name         = "${var.identifier}-${var.environment}-DeploymentTemplateConfigs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  range_key    = "name"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "path"
    type = "S"
  }

  #  attribute {
  #    name = "variables"
  #    type = "S"
  #  }

  global_secondary_index {
    name            = "Name-Path-index"
    hash_key        = "name"
    range_key       = "path"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "client_deployment_template_configs" {
  name         = "${var.identifier}-${var.environment}-ClientDeploymentTemplateConfigs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "client_template_id"
  #  range_key    = "deployment_path"

  attribute {
    name = "client_template_id"
    type = "S"
  }

  #  attribute {
  #    name = "variables"
  #    type = "S"
  #  }

  #  attribute {
  #    name = "deployment_path"
  #    type = "S"
  #  }
}

resource "aws_dynamodb_table" "client_configs" {
  name         = "${var.identifier}-${var.environment}-ClientConfigs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  #  range_key    = "identifier"

  attribute {
    name = "uuid"
    type = "S"
  }

  #  attribute {
  #    name = "identifier"
  #    type = "S"
  #  }

  #  attribute {
  #    name = "information"
  #    type = "S"
  #  }
  #
  #  attribute {
  #    name = "crendential"
  #    type = "S"
  #  }
}

resource "aws_dynamodb_table" "deployment_history" {
  name         = "${var.identifier}-${var.environment}-DeploymentHistory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "client_template_id"
  #  range_key    = "status"

  attribute {
    name = "client_template_id"
    type = "S"
  }

  #  attribute {
  #    name = "variable"
  #    type = "S"
  #  }

  #  attribute {
  #    name = "status"
  #    type = "S"
  #  }
}