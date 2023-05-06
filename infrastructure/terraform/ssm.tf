resource "aws_ssm_parameter" "gitlab_deployment_hub_token" {
  name  = "/${var.identifier}/${var.environment}/deployment/gitlab.token"
  type  = "String"
  value = "override"

  lifecycle {
    ignore_changes = [
      # Value need to be overridden to have proper gitlab token.
      # Don't want to replace it with dummy value on every deployment.
      value
    ]
  }
}