data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.mjs"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

data "aws_iam_role" "lambda_apigateway_role" {
  name = "lambda-apigateway-role"
}

resource "aws_lambda_function" "lambda_function_over_https" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "LambdaFunctionOverHttps"
  role             = data.aws_iam_role.lambda_apigateway_role.arn
  handler          = "lambda_function.handler"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  tags             = var.tags

  environment {
    variables = {
      TABLE_NAME = "todos"
      # Change par la vraie table si besoin
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "dynamo_db_operations" {
  name        = "DynamoDBOperations"
  description = "API pour les opérations sur DynamoDB"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

# Resources pour /todos et /todos/{id}
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  parent_id   = aws_api_gateway_rest_api.dynamo_db_operations.root_resource_id
  path_part   = "todos"
}

resource "aws_api_gateway_resource" "todos_id" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}"
}

# -- /todos - GET
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "get_todos" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos.id
  http_method         = "GET"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration" "get_todos" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}
resource "aws_api_gateway_integration_response" "get_todos" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos.id
  http_method         = "GET"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on          = [aws_api_gateway_integration.get_todos]
}

# -- /todos - POST
resource "aws_api_gateway_method" "post_todos" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "post_todos" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos.id
  http_method         = "POST"
  status_code         = "201"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration" "post_todos" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}
resource "aws_api_gateway_integration_response" "post_todos" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos.id
  http_method         = "POST"
  status_code         = "201"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on          = [aws_api_gateway_integration.post_todos]
}

# -- /todos/{id} - PUT
resource "aws_api_gateway_method" "put_todos_id" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos_id.id
  http_method   = "PUT"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "put_todos_id" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos_id.id
  http_method         = "PUT"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration" "put_todos_id" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos_id.id
  http_method             = "PUT"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}
resource "aws_api_gateway_integration_response" "put_todos_id" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos_id.id
  http_method         = "PUT"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on          = [aws_api_gateway_integration.put_todos_id]
}

# -- /todos/{id} - DELETE
resource "aws_api_gateway_method" "delete_todos_id" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "delete_todos_id" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos_id.id
  http_method         = "DELETE"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration" "delete_todos_id" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos_id.id
  http_method             = "DELETE"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}
resource "aws_api_gateway_integration_response" "delete_todos_id" {
  rest_api_id         = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id         = aws_api_gateway_resource.todos_id.id
  http_method         = "DELETE"
  status_code         = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on          = [aws_api_gateway_integration.delete_todos_id]
}

# -- /todos (OPTIONS pour CORS)
resource "aws_api_gateway_method" "options_todos" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options_todos" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}
resource "aws_api_gateway_integration" "options_todos" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = "OPTIONS"
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_integration_response" "options_todos" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
  depends_on = [aws_api_gateway_integration.options_todos]
}

# -- /todos/{id} (OPTIONS pour CORS)
resource "aws_api_gateway_method" "options_todos_id" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.todos_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options_todos_id" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.todos_id.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}
resource "aws_api_gateway_integration" "options_todos_id" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.todos_id.id
  http_method             = "OPTIONS"
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_integration_response" "options_todos_id" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.todos_id.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'PUT,DELETE,OPTIONS'"
  }
  depends_on = [aws_api_gateway_integration.options_todos_id]
}

# CloudWatch Log Group, policy, attachements...
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_over_https.function_name}"
  retention_in_days = 14
  tags              = var.tags
}

data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_logs" {
  name   = "lambda-cloudwatch-logs"
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = data.aws_iam_role.lambda_apigateway_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}
