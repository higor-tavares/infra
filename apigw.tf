resource "aws_apigatewayv2_api" "api" {
  name          = "webhook-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /webhook"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY" 
  integration_uri  = module.lambda_function.lambda_function_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*"
}

resource "aws_apigatewayv2_stage" "http_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "sandbox"
   access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_v2_log_group.arn
    format  = "requestId [$context.requestId] time:[$context.requestTime] method:[$context.httpMethod] routeKey:[$context.routeKey] response_status: [$context.status]"
  }

  auto_deploy = true
}


resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "authorizer"
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    issuer   = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
    audience = ["${aws_cognito_user_pool_client.app_client.id}"]
  }
}
