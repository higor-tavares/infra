resource "aws_cognito_user_pool" "pool" {
  name = "payments_webhook"
}

resource "aws_cognito_user_pool_client" "app_client" {
  name = "postman-client-app"

  user_pool_id = aws_cognito_user_pool.pool.id
  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "hours"
  }
  refresh_token_validity = 1
  access_token_validity  = 300
  id_token_validity      = 5
  generate_secret = true
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation = true
  allowed_oauth_flows = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["webhook/write"]
  depends_on = [ aws_cognito_resource_server.resource ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "dd5dcbea-a19a-4e6f-9ab2-d9fbdbdeb516"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "webhook"
  name       = "webhook"

  scope {
    scope_name        = "write"
    scope_description = "Write messages"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}