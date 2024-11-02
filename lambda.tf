module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name      = "pix_payment_webhook"
  description        = "Webhook payment processor for pix Payment Method"
  handler            = "main.lambda_handler"
  runtime            = "python3.12"
  source_path        = "./lambda"
  attach_policy_json = true
  environment_variables = {
    "QUEUE_URL" = "https://sqs.${local.region}.amazonaws.com/${local.account}/pix_payment_queue"
  }
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = "arn:aws:sqs:${local.region}:${local.account}:pix_payment_queue"
      }
    ]
  })
  tags = {
    Name = "pix_payment_webhook"
  }
}

resource "aws_sqs_queue" "pix_payment_queue" {
  name                      = "pix_payment_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  tags = {
    Environment = "production"
  }
}
