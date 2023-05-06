resource "aws_sqs_queue" "deployment_request" {
  name                        = "${var.identifier}-${var.environment}-deployment-request.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}