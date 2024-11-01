resource "aws_api_gateway_rest_api" "api" {
  name = "webhook_apigw"
}

resource "aws_api_gateway_resource" "apigw-resource" {
    path_part = "webhook"
    parent_id = aws_api_gateway_rest_api.api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "apigw-method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.apigw-resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.apigw-resource.id
  http_method = aws_api_gateway_method.apigw-method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_function.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:us-west-1:418272752891:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.apigw-method.http_method}${aws_api_gateway_resource.apigw-resource.path}"
}
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "development"
}
