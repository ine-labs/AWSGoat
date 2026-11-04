terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.24.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "resources/lambda/react"
  output_path = "resources/lambda/out/reactapp.zip"
  depends_on  = [aws_s3_object.upload_folder_prod]
}

resource "aws_lambda_function" "react_lambda_app" {
  filename      = "resources/lambda/out/reactapp.zip"
  function_name = "blog-application"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.blog_app_lambda.arn
  depends_on    = [data.archive_file.lambda_zip, null_resource.file_replacement_lambda_react]
}


/* Lambda iam Role */

resource "aws_iam_role" "blog_app_lambda" {
  name = "blog_app_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ba_lambda_attach_2" {
  role       = aws_iam_role.blog_app_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
resource "aws_iam_role_policy_attachment" "ba_lambda_attach_3" {
  role       = aws_iam_role.blog_app_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}


resource "aws_api_gateway_rest_api" "api" {
  name = "blog-application"
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
}


resource "aws_api_gateway_resource" "endpoint" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "react"
}

resource "aws_api_gateway_method" "endpoint" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.endpoint.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "endpoint" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint.id
  http_method = aws_api_gateway_method.endpoint.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }

}

resource "aws_api_gateway_integration" "endpoint" {
  depends_on = [aws_api_gateway_method.endpoint, aws_api_gateway_method_response.endpoint]

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_method.endpoint.resource_id
  http_method             = aws_api_gateway_method.endpoint.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.react_lambda_app.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_integration_response" "endpoint" {
  depends_on = [aws_api_gateway_integration.endpoint]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint.id
  http_method = aws_api_gateway_method.endpoint.http_method
  status_code = aws_api_gateway_method_response.endpoint.status_code

  response_templates = {
    "text/html" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
  }
}

resource "aws_lambda_permission" "apigw_ba" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.react_lambda_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}




resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deployed endpoint at ${timestamp()}"
  depends_on  = [aws_api_gateway_integration_response.endpoint]
}

resource "aws_api_gateway_stage" "api" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
}




/* API Gateway -- REST API lambda_ba */


resource "aws_api_gateway_rest_api" "apiLambda_ba" {
  name           = "blog-application-api"
  api_key_source = "HEADER"
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
}


/* API ENDPOINTS */

# XSS
#########################################################################################################################
resource "aws_api_gateway_resource" "xss_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "xss"
}
resource "aws_api_gateway_method" "proxy_xss_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.xss_root.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "proxy_xss_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.proxy_xss_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "xss_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.xss_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "xss_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.xss_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "lambda_xss_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.proxy_xss_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_integration_response" "lambda_xss_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.proxy_xss_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_xss_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_xss_root_post, aws_api_gateway_method_response.proxy_xss_root_post_response_200]
}

resource "aws_api_gateway_integration" "lambda_xss_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.xss_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_xss_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.xss_root.id
  http_method = aws_api_gateway_method.xss_root_options.http_method
  status_code = aws_api_gateway_method_response.xss_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }
  depends_on = [aws_api_gateway_integration.lambda_xss_root_options]

}
#########################################################################################################################






# BAN-USER
#########################################################################################################################
resource "aws_api_gateway_resource" "ban_user_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "ban-user"
}
resource "aws_api_gateway_method" "proxy_ban_user_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.ban_user_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_ban_user_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.proxy_ban_user_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "ban_user_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.ban_user_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "ban_user_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.ban_user_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


#ban-user
resource "aws_api_gateway_integration" "lambda_ban_user_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.proxy_ban_user_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_ban_user_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.proxy_ban_user_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_ban_user_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_ban_user_root_post]

}

resource "aws_api_gateway_integration" "lambda_ban_user_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.ban_user_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_ban_user_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.ban_user_root.id
  http_method = aws_api_gateway_method.ban_user_root_options.http_method
  status_code = aws_api_gateway_method_response.ban_user_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_ban_user_root_options]

}


#########################################################################################################################




# Change-password
#########################################################################################################################
resource "aws_api_gateway_resource" "change_password_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "change-password"
}

# change-password api methods
resource "aws_api_gateway_method" "proxy_change_password_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.change_password_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_change_password_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.proxy_change_password_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "change_password_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.change_password_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "change_password_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.change_password_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}



# change-password
resource "aws_api_gateway_integration" "lambda_change_password_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.proxy_change_password_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_password_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.proxy_change_password_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_change_password_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_change_password_root_post]

}


resource "aws_api_gateway_integration" "lambda_change_password_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.change_password_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_password_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_password_root.id
  http_method = aws_api_gateway_method.change_password_root_options.http_method
  status_code = aws_api_gateway_method_response.change_password_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_change_password_root_options]

}



#########################################################################################################################






# DUMP-ROOT
#########################################################################################################################
resource "aws_api_gateway_resource" "dump_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "dump"
}

resource "aws_api_gateway_method" "proxy_dump_root_get" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.dump_root.id
  http_method   = "GET"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_dump_root_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.proxy_dump_root_get.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_method" "dump_root_options" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.dump_root.id
  http_method   = "OPTIONS"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "dump_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.dump_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


# dump
resource "aws_api_gateway_integration" "lambda_dump_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.proxy_dump_root_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_dump_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.proxy_dump_root_get.http_method
  status_code = aws_api_gateway_method_response.dump_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_dump_root_post]

}

resource "aws_api_gateway_integration" "lambda_dump_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.dump_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_dump_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.dump_root.id
  http_method = aws_api_gateway_method.dump_root_options.http_method
  status_code = aws_api_gateway_method_response.dump_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_dump_root_options]

}
#########################################################################################################################









# LIST-POSTS
#########################################################################################################################
resource "aws_api_gateway_resource" "list_posts_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "list-posts"
}



# list_posts methods

resource "aws_api_gateway_method" "proxy_list_posts_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.list_posts_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_list_posts_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.proxy_list_posts_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_method" "list_posts_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.list_posts_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "list_posts_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.list_posts_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


# list-posts
resource "aws_api_gateway_integration" "lambda_list_posts_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.proxy_list_posts_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_list_posts_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.proxy_list_posts_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_list_posts_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_list_posts_root_post]

}

resource "aws_api_gateway_integration" "lambda_list_posts_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.list_posts_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_list_posts_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.list_posts_root.id
  http_method = aws_api_gateway_method.list_posts_root_options.http_method
  status_code = aws_api_gateway_method_response.list_posts_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_list_posts_root_options]

}


#########################################################################################################################


#LOGIN-ROOT
#########################################################################################################################
resource "aws_api_gateway_resource" "login_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "login"
}

# login methods

resource "aws_api_gateway_method" "proxy_login_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.login_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_login_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.proxy_login_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "login_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.login_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "login_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.login_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}



# login
resource "aws_api_gateway_integration" "lambda_login_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.proxy_login_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_login_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.proxy_login_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_login_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_login_root_post]

}

resource "aws_api_gateway_integration" "lambda_login_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.login_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_login_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.login_root.id
  http_method = aws_api_gateway_method.login_root_options.http_method
  status_code = aws_api_gateway_method_response.login_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_login_root_options]

}

#########################################################################################################################





# Register-root
#########################################################################################################################
resource "aws_api_gateway_resource" "register_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "register"
}


# register methods

resource "aws_api_gateway_method" "proxy_register_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.register_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_register_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.proxy_register_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "register_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.register_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }
}
resource "aws_api_gateway_method_response" "register_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.register_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


# register
resource "aws_api_gateway_integration" "lambda_register_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.proxy_register_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_register_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.proxy_register_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_register_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_register_root_post]

}


resource "aws_api_gateway_integration" "lambda_register_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.register_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_register_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.register_root.id
  http_method = aws_api_gateway_method.register_root_options.http_method
  status_code = aws_api_gateway_method_response.register_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_register_root_options]

}

#########################################################################################################################



# SAVE-POST
#########################################################################################################################
resource "aws_api_gateway_resource" "save_post_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "save-post"
}

# save-post methods
resource "aws_api_gateway_method" "proxy_save_post_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.save_post_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_save_post_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.proxy_save_post_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "save_post_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.save_post_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "save_post_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.save_post_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

# save-post
resource "aws_api_gateway_integration" "lambda_save_post_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.proxy_save_post_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_save_post_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.proxy_save_post_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_save_post_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_save_post_root_post]
}

resource "aws_api_gateway_integration" "lambda_save_post_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.save_post_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_save_post_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_post_root.id
  http_method = aws_api_gateway_method.save_post_root_options.http_method
  status_code = aws_api_gateway_method_response.save_post_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_save_post_root_options]
}

#########################################################################################################################



# Verify root
#########################################################################################################################
resource "aws_api_gateway_resource" "verify_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "verify"
}



# verify methods

resource "aws_api_gateway_method" "proxy_verify_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.verify_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_verify_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.proxy_verify_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "verify_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.verify_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "verify_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.verify_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}



# verify
resource "aws_api_gateway_integration" "lambda_verify_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.proxy_verify_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_verify_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.proxy_verify_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_verify_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_verify_root_post]

}

resource "aws_api_gateway_integration" "lambda_verify_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.verify_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_verify_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.verify_root.id
  http_method = aws_api_gateway_method.verify_root_options.http_method
  status_code = aws_api_gateway_method_response.verify_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_verify_root_options]
}

#########################################################################################################################




# save-content
#########################################################################################################################

resource "aws_api_gateway_resource" "save_content_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "save-content"
}


# save-content method
resource "aws_api_gateway_method" "proxy_save_content_root_get" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.save_content_root.id
  http_method   = "GET"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_save_content_root_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_get.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "save_content_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.save_content_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "save_content_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.save_content_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "save_content_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.save_content_options.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "save_content_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.save_content_options.http_method
  status_code = aws_api_gateway_method_response.save_content_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.save_content_root_options]
}

resource "aws_api_gateway_method" "proxy_save_content_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.save_content_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_save_content_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


# save-content
resource "aws_api_gateway_integration" "lambda_save_content_root_get" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_save_content_root_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_get.http_method
  status_code = aws_api_gateway_method_response.proxy_save_content_root_get_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_save_content_root_get]

}

resource "aws_api_gateway_integration" "lambda_save_content_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_save_content_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.save_content_root.id
  http_method = aws_api_gateway_method.proxy_save_content_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_save_content_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_save_content_root_post]

}
#########################################################################################################################


# search-author
#########################################################################################################################
resource "aws_api_gateway_resource" "search_author_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "search-author"
}

#search-author method
resource "aws_api_gateway_method" "proxy_search_author_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.search_author_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_search_author_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.proxy_search_author_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "search_author_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.search_author_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "search_author_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.search_author_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "search_author_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.search_author_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "search_author_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.search_author_options.http_method
  status_code = aws_api_gateway_method_response.search_author_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.search_author_root_options]
}

resource "aws_api_gateway_integration" "lambda_search_author_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.proxy_search_author_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_search_author_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.search_author_root.id
  http_method = aws_api_gateway_method.proxy_search_author_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_search_author_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_search_author_root_post]

}

#########################################################################################################################



# reset-password-ROOT
#########################################################################################################################
resource "aws_api_gateway_resource" "reset_password_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "reset-password"
}

resource "aws_api_gateway_method" "proxy_reset_password_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.reset_password_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_reset_password_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.proxy_reset_password_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_method" "reset_password_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.reset_password_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "reset_password_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.reset_password_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_reset_password_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.proxy_reset_password_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_reset_password_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.proxy_reset_password_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_reset_password_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_reset_password_root_post]

}

resource "aws_api_gateway_integration" "lambda_reset_password_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.reset_password_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_reset_password_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.reset_password_root.id
  http_method = aws_api_gateway_method.reset_password_root_options.http_method
  status_code = aws_api_gateway_method_response.reset_password_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_reset_password_root_options]

}
#########################################################################################################################



# get-users-ROOT
#########################################################################################################################
resource "aws_api_gateway_resource" "get_users_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "get-users"
}

resource "aws_api_gateway_method" "proxy_get_users_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.get_users_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_get_users_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.proxy_get_users_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_method" "get_users_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.get_users_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "get_users_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.get_users_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_get_users_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.proxy_get_users_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_get_users_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.proxy_get_users_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_get_users_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_get_users_root_post]

}

resource "aws_api_gateway_integration" "lambda_get_users_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.get_users_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_get_users_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_users_root.id
  http_method = aws_api_gateway_method.get_users_root_options.http_method
  status_code = aws_api_gateway_method_response.get_users_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }

  depends_on = [aws_api_gateway_integration.lambda_get_users_root_options]

}
#########################################################################################################################




#  UNBAN-USER
#########################################################################################################################
resource "aws_api_gateway_resource" "unban_user_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "unban-user"
}
resource "aws_api_gateway_method" "proxy_unban_user_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.unban_user_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_unban_user_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.proxy_unban_user_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "unban_user_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.unban_user_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "unban_user_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.unban_user_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_unban_user_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.proxy_unban_user_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_unban_user_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.proxy_unban_user_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_unban_user_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_unban_user_root_post]

}

resource "aws_api_gateway_integration" "lambda_unban_user_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.unban_user_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_unban_user_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.unban_user_root.id
  http_method = aws_api_gateway_method.unban_user_root_options.http_method
  status_code = aws_api_gateway_method_response.unban_user_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_unban_user_root_options]

}


#########################################################################################################################



#  USER-DETAILS-MODAL
#########################################################################################################################
resource "aws_api_gateway_resource" "user_details_modal_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "user-details-modal"
}
resource "aws_api_gateway_method" "proxy_user_details_modal_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.user_details_modal_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_user_details_modal_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.proxy_user_details_modal_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "user_details_modal_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.user_details_modal_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}

resource "aws_api_gateway_method_response" "user_details_modal_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.user_details_modal_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_user_details_modal_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.proxy_user_details_modal_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_user_details_modal_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.proxy_user_details_modal_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_user_details_modal_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_user_details_modal_root_post]

}

resource "aws_api_gateway_integration" "lambda_user_details_modal_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.user_details_modal_root_options.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_user_details_modal_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.user_details_modal_root.id
  http_method = aws_api_gateway_method.user_details_modal_root_options.http_method
  status_code = aws_api_gateway_method_response.user_details_modal_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_user_details_modal_root_options]

}


#########################################################################################################################



#  DELETE-USER
#########################################################################################################################
resource "aws_api_gateway_resource" "delete_user_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "delete-user"
}
resource "aws_api_gateway_method" "proxy_delete_user_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.delete_user_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_delete_user_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.proxy_delete_user_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "delete_user_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.delete_user_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "delete_user_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.delete_user_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_delete_user_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.proxy_delete_user_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_delete_user_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.proxy_delete_user_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_delete_user_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_delete_user_root_post]

}

resource "aws_api_gateway_integration" "lambda_delete_user_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.delete_user_root_options.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_delete_user_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.delete_user_root.id
  http_method = aws_api_gateway_method.delete_user_root_options.http_method
  status_code = aws_api_gateway_method_response.delete_user_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_delete_user_root_options]

}


#########################################################################################################################



#  CHANGE-AUTH
#########################################################################################################################
resource "aws_api_gateway_resource" "change_auth_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "change-auth"
}
resource "aws_api_gateway_method" "proxy_change_auth_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.change_auth_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_change_auth_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.proxy_change_auth_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "change_auth_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.change_auth_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "change_auth_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.change_auth_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_change_auth_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.proxy_change_auth_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_auth_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.proxy_change_auth_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_change_auth_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_change_auth_root_post]

}

resource "aws_api_gateway_integration" "lambda_change_auth_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.change_auth_root_options.http_method

  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_auth_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_auth_root.id
  http_method = aws_api_gateway_method.change_auth_root_options.http_method
  status_code = aws_api_gateway_method_response.change_auth_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_change_auth_root_options]

}


#########################################################################################################################



#  MODIFY-POST-STATUS
#########################################################################################################################
resource "aws_api_gateway_resource" "modify_post_status_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "modify-post-status"
}
resource "aws_api_gateway_method" "proxy_modify_post_status_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.modify_post_status_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_modify_post_status_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.proxy_modify_post_status_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "modify_post_status_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.modify_post_status_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "modify_post_status_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.modify_post_status_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_modify_post_status_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.proxy_modify_post_status_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_modify_post_status_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.proxy_modify_post_status_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_modify_post_status_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_modify_post_status_root_post]

}

resource "aws_api_gateway_integration" "lambda_modify_post_status_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.modify_post_status_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_modify_post_status_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.modify_post_status_root.id
  http_method = aws_api_gateway_method.modify_post_status_root_options.http_method
  status_code = aws_api_gateway_method_response.modify_post_status_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_modify_post_status_root_options]

}

#########################################################################################################################


# GET-DASHBOARD
#########################################################################################################################
resource "aws_api_gateway_resource" "get_dashboard_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "get-dashboard"
}
resource "aws_api_gateway_method" "proxy_get_dashboard_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.get_dashboard_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_get_dashboard_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.proxy_get_dashboard_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "get_dashboard_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.get_dashboard_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "get_dashboard_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.get_dashboard_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_get_dashboard_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.proxy_get_dashboard_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_get_dashboard_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.proxy_get_dashboard_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_get_dashboard_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_get_dashboard_root_post]

}

resource "aws_api_gateway_integration" "lambda_get_dashboard_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.get_dashboard_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_get_dashboard_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.get_dashboard_root.id
  http_method = aws_api_gateway_method.get_dashboard_root_options.http_method
  status_code = aws_api_gateway_method_response.get_dashboard_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_get_dashboard_root_options]

}

#########################################################################################################################



# CHANGE-PROFILE
#########################################################################################################################
resource "aws_api_gateway_resource" "change_profile_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  parent_id   = aws_api_gateway_rest_api.apiLambda_ba.root_resource_id
  path_part   = "change-profile"
}
resource "aws_api_gateway_method" "proxy_change_profile_root_post" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id   = aws_api_gateway_resource.change_profile_root.id
  http_method   = "POST"
  authorization = "NONE"

}
resource "aws_api_gateway_method_response" "proxy_change_profile_root_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.proxy_change_profile_root_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "change_profile_root_options" {
  rest_api_id        = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id        = aws_api_gateway_resource.change_profile_root.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.header.JWT_TOKEN" = false }

}
resource "aws_api_gateway_method_response" "change_profile_root_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.change_profile_root_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "lambda_change_profile_root_post" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.proxy_change_profile_root_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_ba_data.invoke_arn
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_profile_root_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.proxy_change_profile_root_post.http_method
  status_code = aws_api_gateway_method_response.proxy_change_profile_root_post_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }


  depends_on = [aws_api_gateway_integration.lambda_change_profile_root_post]

}

resource "aws_api_gateway_integration" "lambda_change_profile_root_options" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.change_profile_root_options.http_method


  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}
resource "aws_api_gateway_integration_response" "lambda_change_profile_root_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  resource_id = aws_api_gateway_resource.change_profile_root.id
  http_method = aws_api_gateway_method.change_profile_root_options.http_method
  status_code = aws_api_gateway_method_response.change_profile_root_options_response_200.status_code


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,JWT_TOKEN'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",

  }



  depends_on = [aws_api_gateway_integration.lambda_change_profile_root_options]

}

#########################################################################################################################


/* Deploying the API with stage name i.e data */

resource "aws_api_gateway_deployment" "apideploy_ba" {
  depends_on = [
    aws_api_gateway_integration_response.save_content_root_options_integration_response,
    aws_api_gateway_integration_response.search_author_root_options_integration_response,


    aws_api_gateway_integration_response.lambda_xss_root_post_integration_response,
    aws_api_gateway_method_response.proxy_xss_root_post_response_200,
    aws_api_gateway_integration.lambda_xss_root_post,

    aws_api_gateway_integration_response.lambda_ban_user_root_post_integration_response,
    aws_api_gateway_method_response.proxy_ban_user_root_post_response_200,
    aws_api_gateway_integration.lambda_ban_user_root_post,

    aws_api_gateway_integration_response.lambda_change_password_root_post_integration_response,
    aws_api_gateway_method_response.proxy_change_password_root_post_response_200,
    aws_api_gateway_integration.lambda_change_password_root_post,

    aws_api_gateway_integration_response.lambda_dump_root_post_integration_response,
    aws_api_gateway_method_response.proxy_dump_root_get_response_200,
    aws_api_gateway_integration.lambda_dump_root_post,

    aws_api_gateway_integration_response.lambda_list_posts_root_post_integration_response,
    aws_api_gateway_method_response.proxy_list_posts_root_post_response_200,
    aws_api_gateway_integration.lambda_list_posts_root_post,

    aws_api_gateway_integration_response.lambda_login_root_post_integration_response,
    aws_api_gateway_method_response.proxy_login_root_post_response_200,
    aws_api_gateway_integration.lambda_login_root_post,

    aws_api_gateway_integration_response.lambda_register_root_post_integration_response,
    aws_api_gateway_method_response.proxy_register_root_post_response_200,
    aws_api_gateway_integration.lambda_register_root_post,

    aws_api_gateway_integration_response.lambda_save_post_root_post_integration_response,
    aws_api_gateway_method_response.proxy_save_post_root_post_response_200,
    aws_api_gateway_integration.lambda_save_post_root_post,

    aws_api_gateway_integration_response.lambda_verify_root_post_integration_response,
    aws_api_gateway_method_response.proxy_verify_root_post_response_200,
    aws_api_gateway_integration.lambda_verify_root_post,

    aws_api_gateway_integration_response.lambda_xss_root_options_integration_response,
    aws_api_gateway_method_response.xss_root_options_response_200,
    aws_api_gateway_integration.lambda_xss_root_options,

    aws_api_gateway_integration_response.lambda_ban_user_root_options_integration_response,
    aws_api_gateway_method_response.ban_user_root_options_response_200,
    aws_api_gateway_integration.lambda_ban_user_root_options,

    aws_api_gateway_integration_response.lambda_change_password_root_options_integration_response,
    aws_api_gateway_method_response.change_password_root_options_response_200,
    aws_api_gateway_integration.lambda_change_password_root_options,

    aws_api_gateway_integration_response.lambda_dump_root_options_integration_response,
    aws_api_gateway_method_response.dump_root_options_response_200,
    aws_api_gateway_integration.lambda_dump_root_options,

    aws_api_gateway_integration_response.lambda_list_posts_root_options_integration_response,
    aws_api_gateway_method_response.list_posts_root_options_response_200,
    aws_api_gateway_integration.lambda_list_posts_root_options,

    aws_api_gateway_integration_response.lambda_login_root_options_integration_response,
    aws_api_gateway_method_response.login_root_options_response_200,
    aws_api_gateway_integration.lambda_login_root_options,

    aws_api_gateway_integration_response.lambda_register_root_options_integration_response,
    aws_api_gateway_method_response.register_root_options_response_200,
    aws_api_gateway_integration.lambda_register_root_options,

    aws_api_gateway_integration_response.lambda_save_post_root_options_integration_response,
    aws_api_gateway_method_response.save_post_root_options_response_200,
    aws_api_gateway_integration.lambda_save_post_root_options,

    aws_api_gateway_integration_response.lambda_verify_root_options_integration_response,
    aws_api_gateway_method_response.verify_root_options_response_200,
    aws_api_gateway_integration.lambda_verify_root_options,

    # Moved to one api

    aws_api_gateway_integration_response.lambda_save_content_root_get_integration_response,
    aws_api_gateway_method_response.proxy_save_content_root_get_response_200,
    aws_api_gateway_integration.lambda_save_content_root_get,

    aws_api_gateway_integration_response.lambda_save_content_root_post_integration_response,
    aws_api_gateway_method_response.proxy_save_content_root_post_response_200,
    aws_api_gateway_integration.lambda_save_content_root_post,

    aws_api_gateway_integration_response.lambda_search_author_root_post_integration_response,
    aws_api_gateway_method_response.proxy_search_author_root_post_response_200,
    aws_api_gateway_integration.lambda_search_author_root_post,


    # New ones

    aws_api_gateway_integration_response.lambda_get_users_root_post_integration_response,
    aws_api_gateway_method_response.proxy_get_users_root_post_response_200,
    aws_api_gateway_integration.lambda_get_users_root_post,

    aws_api_gateway_integration_response.lambda_reset_password_root_post_integration_response,
    aws_api_gateway_method_response.proxy_reset_password_root_post_response_200,
    aws_api_gateway_integration.lambda_reset_password_root_post,

    aws_api_gateway_integration_response.lambda_unban_user_root_post_integration_response,
    aws_api_gateway_method_response.proxy_unban_user_root_post_response_200,
    aws_api_gateway_integration.lambda_unban_user_root_post,

    aws_api_gateway_integration_response.lambda_delete_user_root_post_integration_response,
    aws_api_gateway_method_response.proxy_delete_user_root_post_response_200,
    aws_api_gateway_integration.lambda_delete_user_root_post,

    aws_api_gateway_integration_response.lambda_change_auth_root_post_integration_response,
    aws_api_gateway_method_response.proxy_change_auth_root_post_response_200,
    aws_api_gateway_integration.lambda_change_auth_root_post,

    aws_api_gateway_integration_response.lambda_modify_post_status_root_post_integration_response,
    aws_api_gateway_method_response.proxy_modify_post_status_root_post_response_200,
    aws_api_gateway_integration.lambda_modify_post_status_root_post,

    aws_api_gateway_integration_response.lambda_get_dashboard_root_post_integration_response,
    aws_api_gateway_method_response.proxy_get_dashboard_root_post_response_200,
    aws_api_gateway_integration.lambda_get_dashboard_root_post,

    aws_api_gateway_integration_response.lambda_change_profile_root_post_integration_response,
    aws_api_gateway_method_response.proxy_change_profile_root_post_response_200,
    aws_api_gateway_integration.lambda_change_profile_root_post,
  ]

  rest_api_id = aws_api_gateway_rest_api.apiLambda_ba.id
  stage_name  = "v1"
  variables = {
    "BLOG_KEY" = "655877f0f8ade541e1d21a48fe396ddb"
  }
}

/* Lambda Setup - blog-application-data*/

data "archive_file" "lambda_zip_bap" {
  type        = "zip"
  source_file = "resources/lambda/data/lambda_function.py"
  output_path = "resources/lambda/out/data_app.zip"
  depends_on = [
    null_resource.file_replacement_lambda_data
  ]
}
resource "aws_lambda_layer_version" "lambda_layer" {
  filename                 = "resources/lambda/layer/bcrypt-pyjwt.zip"
  layer_name               = "bcrypt-pyjwt"
  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["python3.9"]
}

resource "aws_lambda_function" "lambda_ba_data" {
  filename      = "resources/lambda/out/data_app.zip"
  function_name = "blog-application-data"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.blog_app_lambda_python.arn
  depends_on    = [data.archive_file.lambda_zip_bap]
  layers        = [aws_lambda_layer_version.lambda_layer.arn]
  memory_size   = "256"
  environment {
    variables = {
      JWT_SECRET = "T2BYL6#]zc>Byuzu"
    }
  }
}


/* Lambda iam Role */

resource "aws_iam_role" "blog_app_lambda_python" {
  name = "blog_app_lambda_data"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "blog_app_policy" {
  role       = aws_iam_role.blog_app_lambda_python.name
  policy_arn = aws_iam_policy.lambda_data_policies.arn
}

resource "aws_iam_policy" "lambda_data_policies" {
  name = "lambda-data-policies"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "s3:*",
          "s3-object-lambda:*",
          "autoscaling:Describe*",
          "cloudwatch:*",
          "logs:*",
          "sns:*",
          "dynamodb:*",
          "dax:*",
          "lambda:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "Pol1"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ],
        "Resource" : "arn:aws:execute-api:*:*:*"
      }
    ],
    "Version" : "2012-10-17"
  })
}


resource "aws_lambda_permission" "apigw_ba_python" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ba_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda_ba.execution_arn}/*/*"
}



# s3 bucket for all dev files & folder for post images


/* Local Variable for mime_types */

locals {
  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    sh   = "application/x-sh"
  }
}




/* Creating a S3 Bucket for webfiles files upload. */
resource "aws_s3_bucket" "bucket_upload" {
  bucket        = "production-blog-awsgoat-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags = {
    Name        = "Production bucket"
    Environment = "Prod"
  }
}

# ACL fixes required for AWS S3 APR 2023 updates.
resource "aws_s3_bucket_public_access_block" "bucket_upload" {
  bucket = aws_s3_bucket.bucket_upload.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "bucket_upload" {
  bucket = aws_s3_bucket.bucket_upload.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_upload" {
  depends_on = [
	aws_s3_bucket_public_access_block.bucket_upload,
	aws_s3_bucket_ownership_controls.bucket_upload,
  ]

  bucket = aws_s3_bucket.bucket_upload.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_for_prod" {
  bucket = aws_s3_bucket.bucket_upload.id
  policy = data.aws_iam_policy_document.allow_get_access.json

  depends_on = [ aws_s3_bucket_acl.bucket_upload ]
}
data "aws_iam_policy_document" "allow_get_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.bucket_upload.arn,
      "${aws_s3_bucket.bucket_upload.arn}/*",
    ]
  }
}
resource "aws_s3_bucket_cors_configuration" "bucket_upload" {
  bucket = aws_s3_bucket.bucket_upload.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
  }
  depends_on = [aws_s3_bucket_acl.bucket_upload]
}
# Upload in production bucket

resource "aws_s3_object" "upload_folder_prod" {
  for_each     = fileset("./resources/s3/webfiles/", "**")
  bucket       = aws_s3_bucket.bucket_upload.bucket
  key          = each.value
  acl          = "public-read"
  source       = "./resources/s3/webfiles/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  depends_on   = [aws_s3_bucket.bucket_upload, null_resource.file_replacement_api_gw, aws_s3_bucket_acl.bucket_upload]
}


#Development bucket
resource "aws_s3_bucket" "dev" {
  bucket = "dev-blog-awsgoat-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Development bucket"
    Environment = "Dev"
  }
}


# ACL fixes required for AWS S3 APR 2023 updates.
resource "aws_s3_bucket_public_access_block" "dev" {
  bucket = aws_s3_bucket.dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "dev" {
  bucket = aws_s3_bucket.dev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "dev" {
  depends_on = [
	aws_s3_bucket_public_access_block.dev,
	aws_s3_bucket_ownership_controls.dev,
  ]

  bucket = aws_s3_bucket.dev.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_access_for_dev" {
  bucket = aws_s3_bucket.dev.bucket
  policy = data.aws_iam_policy_document.allow_get_list_access.json

  depends_on = [ aws_s3_bucket_acl.dev ]
}
data "aws_iam_policy_document" "allow_get_list_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.dev.arn,
      "${aws_s3_bucket.dev.arn}/*",
    ]
  }
}
# Upload in dev bucket

resource "aws_s3_object" "upload_folder_dev" {
  for_each     = fileset("./resources/s3/webfiles/build/", "**")
  bucket       = aws_s3_bucket.dev.bucket
  key          = each.value
  acl          = "public-read"
  source       = "./resources/s3/webfiles/build/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  depends_on   = [aws_s3_bucket.dev, null_resource.file_replacement_ec2_ip, aws_s3_bucket_acl.dev]
}

resource "aws_s3_object" "upload_folder_dev_2" {
  for_each     = fileset("./resources/s3/shared/", "**")
  bucket       = aws_s3_bucket.dev.bucket
  key          = each.value
  acl          = "public-read"
  source       = "./resources/s3/shared/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  depends_on   = [aws_s3_bucket.dev, null_resource.file_replacement_ec2_ip, aws_s3_bucket_acl.dev]
}


/* Creating a S3 Bucket for ec2-files upload. */
resource "aws_s3_bucket" "bucket_temp" {
  bucket        = "ec2-temp-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name        = "Temporary bucket"
    Environment = "Dev"
  }
}

# ACL fixes required for AWS S3 APR 2023 updates.
resource "aws_s3_bucket_public_access_block" "bucket_temp" {
  bucket = aws_s3_bucket.bucket_temp.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "bucket_temp" {
  bucket = aws_s3_bucket.bucket_temp.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_temp" {
  depends_on = [
	aws_s3_bucket_public_access_block.bucket_temp,
	aws_s3_bucket_ownership_controls.bucket_temp,
  ]

  bucket = aws_s3_bucket.bucket_temp.id
  acl    = "public-read"
}

/* Uploading all files to ec2-temp-bucket-ACCOUNT_ID bucket */

resource "aws_s3_object" "upload_temp_object" {
  for_each     = fileset("./resources/s3/webfiles/build/", "**")
  acl          = "public-read"
  bucket       = aws_s3_bucket.bucket_temp.bucket
  key          = each.value
  source       = "./resources/s3/webfiles/build/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  depends_on   = [aws_s3_bucket.bucket_upload, null_resource.file_replacement_lambda_react, aws_s3_bucket_acl.bucket_temp]
}

resource "aws_s3_object" "upload_temp_object_2" {
  for_each     = fileset("./resources/s3/shared/", "**")
  acl          = "public-read"
  bucket       = aws_s3_bucket.bucket_temp.bucket
  key          = each.value
  source       = "./resources/s3/shared/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  depends_on   = [aws_s3_bucket.bucket_upload, null_resource.file_replacement_lambda_react, aws_s3_bucket_acl.bucket_temp]
}
/* Creating a S3 Bucket for Terraform state file upload. */
resource "aws_s3_bucket" "bucket_tf_files" {
  bucket        = "do-not-delete-awsgoat-state-files-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags = {
    Name        = "Do not delete Bucket"
    Environment = "Dev"
  }
}


# VPC to deploy web app

resource "aws_vpc" "goat_vpc" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "AWS_GOAT_VPC"
  }
}
resource "aws_internet_gateway" "goat_gw" {
  vpc_id = aws_vpc.goat_vpc.id
  tags = {
    Name = "app gateway"
  }
}
resource "aws_subnet" "goat_subnet" {
  vpc_id                  = aws_vpc.goat_vpc.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "AWS_GOAT App subnet"
  }
}

resource "aws_route_table" "goat_rt" {
  vpc_id = aws_vpc.goat_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.goat_gw.id
  }
}
resource "aws_route_table_association" "goat_public_rta" {
  subnet_id      = aws_subnet.goat_subnet.id
  route_table_id = aws_route_table.goat_rt.id
}

resource "aws_security_group" "goat_sg" {
  name        = "AWS_GOAT_sg"
  description = "AWS_GOAT_sg"
  vpc_id      = aws_vpc.goat_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AWS_GOAT_sg"
  }
}


# Instance Requirements
resource "aws_iam_instance_profile" "goat_iam_profile" {
  name = "AWS_GOAT_ec2_profile"
  role = aws_iam_role.goat_role.name
}
resource "aws_iam_role" "goat_role" {
  name               = "AWS_GOAT_ROLE"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "goat_s3_policy" {
  role       = aws_iam_role.goat_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_iam_role_policy_attachment" "goat_policy" {
  role       = aws_iam_role.goat_role.name
  policy_arn = aws_iam_policy.goat_inline_policy_2.arn
}

resource "aws_iam_policy" "goat_inline_policy_2" {
  name = "dev-ec2-lambda-policies"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionEventInvokeConfig",
          "lambda:AddPermission",
          "lambda:InvokeFunction",
          "lambda:GetLayerVersion",
          "lambda:ListVersionsByFunction",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunctionConfiguration",
          "lambda:GetLayerVersionPolicy",
          "lambda:GetPolicy",
          "iam:AttachRolePolicy"
        ],
        "Effect" : "Allow",
        "Resource" : ["${aws_lambda_function.lambda_ba_data.arn}", "${aws_iam_role.blog_app_lambda_python.arn}"],
        "Sid" : "Pol0"
      },
      {
        "Action" : [
          "iam:ListPolicies",
          "iam:GetRole",
          "iam:GetPolicyVersion",
          "lambda:ListFunctions",
          "iam:GetInstanceProfile",
          "iam:GetPolicy",
          "iam:ListRoles",
          "iam:ListInstanceProfileTags",
          "iam:ListInstanceProfiles",
          "iam:CreatePolicy",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "iam:ListPolicyVersions",
          "iam:ListAttachedRolePolicies",
          "lambda:ListLayerVersions",
          "iam:UpdateRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "Pol1"
      }
    ],
    "Version" : "2012-10-17"
  })
}

data "template_file" "goat_script" {
  template = file("resources/ec2/goat_user_data.tpl")
  vars = {
    S3_BUCKET_NAME = aws_s3_bucket.bucket_temp.bucket
  }
  depends_on = [aws_s3_bucket.bucket_temp]
}


data "aws_ami" "goat_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "goat_instance" {
  ami                  = data.aws_ami.goat_ami.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.goat_iam_profile.name
  subnet_id            = aws_subnet.goat_subnet.id
  security_groups      = [aws_security_group.goat_sg.id]
  tags = {
    Name = "AWS_GOAT_DEV_INSTANCE"
  }
  user_data = data.template_file.goat_script.rendered
  depends_on = [
    aws_s3_object.upload_temp_object_2
  ]
}


resource "aws_dynamodb_table" "users_table" {
  name           = "blog-users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2

  hash_key = "email"
  attribute {
    name = "email"
    type = "S"
  }
}
resource "aws_dynamodb_table" "posts_table" {
  name           = "blog-posts"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2

  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
}


resource "null_resource" "populate_table" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i 's/replace-bucket-name/${aws_s3_bucket.bucket_upload.bucket}/g' resources/dynamodb/blog-posts.json
python3 resources/dynamodb/populate-table.py
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [aws_s3_bucket.bucket_upload, aws_dynamodb_table.users_table, aws_dynamodb_table.posts_table]
}


# To replace with IP Address of EC2-Instance in .ssh/config
resource "null_resource" "file_replacement_ec2_ip" {
  provisioner "local-exec" {
    command     = "sed -i 's/EC2_IP_ADDR/${aws_instance.goat_instance.public_ip}/g' resources/s3/shared/shared/files/.ssh/config.txt"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [aws_instance.goat_instance]
}


resource "null_resource" "file_replacement_lambda_react" {
  provisioner "local-exec" {
    command     = "sed -i 's/replace-bucket-name/${aws_s3_bucket.bucket_upload.bucket}/g' resources/lambda/react/index.js"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    aws_s3_bucket.bucket_upload
  ]
}

resource "null_resource" "file_replacement_lambda_data" {
  provisioner "local-exec" {
    command     = "sed -i 's/replace-bucket-name/${aws_s3_bucket.bucket_upload.bucket}/g' resources/lambda/data/lambda_function.py"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    aws_s3_bucket.bucket_upload
  ]
}


resource "null_resource" "file_replacement_api_gw" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i "s,API_GATEWAY_URL,${aws_api_gateway_deployment.apideploy_ba.invoke_url},g" resources/s3/webfiles/build/static/js/main.e5839717.js
sed -i "s,API_GATEWAY_URL,${aws_api_gateway_deployment.apideploy_ba.invoke_url},g" resources/s3/webfiles/build/static/js/main.e5839717.js.map
sed -i 's/"\/static/"https:\/\/${aws_s3_bucket.bucket_upload.bucket}\.s3\.amazonaws\.com\/build\/static/g' resources/s3/webfiles/build/static/js/main.e5839717.js
sed -i 's/n.p+"static/"https:\/\/${aws_s3_bucket.bucket_upload.bucket}\.s3\.amazonaws\.com\/build\/static/g' resources/s3/webfiles/build/static/js/main.e5839717.js
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    aws_api_gateway_deployment.apideploy_ba
  ]
}

/* Replace deployed api gateway url with API_GATEWAY_URL for local terraform reapply */
resource "null_resource" "file_replacement_api_gw_cleanup" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i "s,${aws_api_gateway_deployment.apideploy_ba.invoke_url},API_GATEWAY_URL,g" resources/s3/webfiles/build/static/js/main.e5839717.js
sed -i "s,${aws_api_gateway_deployment.apideploy_ba.invoke_url},API_GATEWAY_URL,g" resources/s3/webfiles/build/static/js/main.e5839717.js.map
sed -i 's/${aws_instance.goat_instance.public_ip}/EC2_IP_ADDR/g' resources/s3/shared/shared/files/.ssh/config.txt
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    aws_s3_object.upload_temp_object, aws_s3_object.upload_temp_object_2, aws_s3_object.upload_folder_dev, aws_s3_object.upload_folder_dev_2, aws_s3_object.upload_folder_prod
  ]
}


output "app_url" {
  value = "${aws_api_gateway_stage.api.invoke_url}/react"
}

