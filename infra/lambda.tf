data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.mjs"
  output_path = "${path.module}/lambda/function.zip"
}

data "aws_iam_role" "lambda_apigateway_role" {
  name = "lambda-apigateway-role"
}

resource "aws_lambda_function" "lambda_function_over_https" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "LambdaFunctionOverHttps"
  role             = data.aws_iam_role.lambda_apigateway_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  tags             = var.tags
}

# apigateway
resource "aws_api_gateway_rest_api" "dynamo_db_operations" {
  name        = "DynamoDBOperations"
  description = "API pour les opérations sur DynamoDB"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

resource "aws_api_gateway_resource" "dynamodb_manager" {
  parent_id   = aws_api_gateway_rest_api.dynamo_db_operations.root_resource_id
  path_part   = "DynamoDBManager"
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method" "post_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method_response" "post_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "post_method" {
  http_method             = aws_api_gateway_method.post_method.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_api_gateway_integration_response" "post_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.post_method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.post_method
  ]
}

resource "aws_api_gateway_method" "get_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method_response" "get_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "get_method" {
  http_method             = aws_api_gateway_method.get_method.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_api_gateway_integration_response" "get_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.get_method
  ]
}

resource "aws_api_gateway_method" "put_method" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method_response" "put_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "put_method" {
  http_method             = aws_api_gateway_method.put_method.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_api_gateway_integration_response" "put_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = aws_api_gateway_method_response.put_method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.put_method
  ]
}

resource "aws_api_gateway_method" "delete_method" {
  authorization = "NONE"
  http_method   = "DELETE"
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method_response" "delete_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.delete_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "delete_method" {
  http_method             = aws_api_gateway_method.delete_method.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_api_gateway_integration_response" "delete_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.delete_method.http_method
  status_code = aws_api_gateway_method_response.delete_method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.delete_method
  ]
}

resource "aws_api_gateway_method" "options_method" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration" "options_method" {
  http_method             = aws_api_gateway_method.options_method.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
  }
  depends_on = [
    aws_api_gateway_integration.options_method
  ]
}