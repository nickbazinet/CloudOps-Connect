resource "aws_cognito_user_pool" "users" {
  name = "${var.identifier}-${var.environment}-user-pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name          = "${var.identifier}-${var.environment}-app-client"
  user_pool_id  = aws_cognito_user_pool.users.id
}