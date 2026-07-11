// Shared trust policy for both roles use 

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// -----------------------------------------------
// The Web Tier Role only needs minimal permissions
// to write to logs to cloudwatch

resource "aws_iam_role" "web_tier" {
  name               = "${var.environment}-web-tier-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name        = "${var.environment}-web-tier-role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "web_tier_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "web_tier" {
  name        = "${var.environment}-web-tier-policy"
  description = "Allows web tier EC2 instances to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.web_tier_permissions.json
}

resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.web_tier.name
  policy_arn = aws_iam_policy.web_tier.arn
}

resource "aws_iam_instance_profile" "web_tier" {
  name = "${var.environment}-web-tier-profile"
  role = aws_iam_role.web_tier.name
}

// -----------------------------------------------
// App Tier Role, the app servers need:
// Secrets Manager (fetch DB credentials)
// S3 (read/write application data)
// CloudWatch (write logs)
resource "aws_iam_role" "app_tier" {
  name               = "${var.environment}-app-tier-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name        = "${var.environment}-app-tier-role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "app_tier_permissions" {
  // Secrets Manager for fetching DB credentials only
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.db_secret_arn]   // scoped to specific secret, not *
  }

  // S3 to read and write to app bucket only
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  // CloudWatch to write logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app_tier" {
  name        = "${var.environment}-app-tier-policy"
  description = "Allows app tier EC2 instances to access Secrets Manager, S3, and CloudWatch"
  policy      = data.aws_iam_policy_document.app_tier_permissions.json
}

resource "aws_iam_role_policy_attachment" "app_tier" {
  role       = aws_iam_role.app_tier.name
  policy_arn = aws_iam_policy.app_tier.arn
}

resource "aws_iam_instance_profile" "app_tier" {
  name = "${var.environment}-app-tier-profile"
  role = aws_iam_role.app_tier.name
}