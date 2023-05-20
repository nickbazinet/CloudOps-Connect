resource "aws_sns_topic" "post_deployment_events" {
  name = "${var.identifier}-${var.environment}-post-deployment"
}