
resource "aws_cloudwatch_log_group" "api_gw_v2_log_group" {
  name              = "/aws/api-gateway-v2/webhook-api"
  retention_in_days = 7
}

resource "aws_iam_role" "api_gw_v2_cloudwatch_role" {
  name = "api-gw-v2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "api_gw_v2_cloudwatch_policy" {
  role = aws_iam_role.api_gw_v2_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}