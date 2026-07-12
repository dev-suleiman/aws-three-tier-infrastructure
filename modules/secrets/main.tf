resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/db/credentials"
  description = "Database credentials for the ${var.environment} environment"

  recovery_window_in_days = 7

  tags = {
    Name        = "${var.environment}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}