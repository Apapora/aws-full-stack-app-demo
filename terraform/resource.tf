resource "aws_iam_role" "dynamo_db_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  force_detach_policies = [
    {
      PolicyName = "GoalsPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "dynamodb:PutItem",
              "dynamodb:Query",
              "dynamodb:UpdateItem",
              "dynamodb:GetItem",
              "dynamodb:Scan",
              "dynamodb:DeleteItem"
            ]
            Resource = aws_dynamodb_table.t_goals.arn
          }
        ]
      }
    }
  ]
}

resource "aws_dynamodb_table" "t_goals" {
  name = var.project_name
  attribute = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "goalId"
      type = "S"
    }
  ]
  // CF Property(KeySchema) = [
  //   {
  //     AttributeName = "userId"
  //     KeyType = "HASH"
  //   },
  //   {
  //     AttributeName = "goalId"
  //     KeyType = "RANGE"
  //   }
  // ]
  // CF Property(ProvisionedThroughput) = {
  //   ReadCapacityUnits = 1
  //   WriteCapacityUnits = 1
  // }
}

resource "aws_lambda_function" "function_list_goals" {
  function_name = "${var.project_name}-ListGoals"
  description = "Get list of goals for userId"
  handler = "index.handler"
  memory_size = 256
  runtime = "nodejs12.x"
  role = aws_iam_role.dynamo_db_role.arn
  timeout = 120
  environment {
    variables = {
      TABLE_NAME = var.project_name
    }
  }
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["ListGoalsCode"]
  }
}

resource "aws_lambda_function" "function_create_goal" {
  function_name = "${var.project_name}-CreateGoal"
  description = "Create goal for user id"
  handler = "index.handler"
  memory_size = 256
  runtime = "nodejs12.x"
  role = aws_iam_role.dynamo_db_role.arn
  timeout = 120
  environment {
    variables = {
      TABLE_NAME = var.project_name
    }
  }
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["CreateGoalCode"]
  }
}

resource "aws_lambda_function" "function_delete_goal" {
  function_name = "${var.project_name}-DeleteGoal"
  description = "Delete goal for user id"
  handler = "index.handler"
  memory_size = 256
  runtime = "nodejs12.x"
  role = aws_iam_role.dynamo_db_role.arn
  timeout = 120
  environment {
    variables = {
      TABLE_NAME = var.project_name
    }
  }
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["DeleteGoalCode"]
  }
}

resource "aws_lambda_function" "function_update_goal" {
  function_name = "${var.project_name}-UpdateGoal"
  description = "Update goal for user id"
  handler = "index.handler"
  memory_size = 256
  runtime = "nodejs12.x"
  role = aws_iam_role.dynamo_db_role.arn
  timeout = 120
  environment {
    variables = {
      TABLE_NAME = var.project_name
    }
  }
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["UpdateGoalCode"]
  }
}

resource "aws_lambda_function" "function_get_goal" {
  function_name = "${var.project_name}-GetGoal"
  description = "Get goal for user id"
  handler = "index.handler"
  memory_size = 256
  runtime = "nodejs12.x"
  role = aws_iam_role.dynamo_db_role.arn
  timeout = 120
  environment {
    variables = {
      TABLE_NAME = var.project_name
    }
  }
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["GetGoalCode"]
  }
}

resource "aws_lambda_permission" "function_list_goals_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_list_goals.arn
  principal = "apigateway.amazonaws.com"
  source_arn = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
}

resource "aws_lambda_permission" "function_create_goal_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_create_goal.arn
  principal = "apigateway.amazonaws.com"
  source_arn = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
}

resource "aws_lambda_permission" "function_delete_goal_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_delete_goal.arn
  principal = "apigateway.amazonaws.com"
  source_arn = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
}

resource "aws_lambda_permission" "function_update_goal_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_update_goal.arn
  principal = "apigateway.amazonaws.com"
  source_arn = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
}

resource "aws_lambda_permission" "function_get_goal_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_get_goal.arn
  principal = "apigateway.amazonaws.com"
  source_arn = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
}

resource "aws_api_gateway_rest_api" "app_api" {
  name = var.project_name
  description = "API used for Goals requests"
  fail_on_warnings = True
}

resource "aws_api_gateway_method" "goals_api_request_get" {
  authorization = "AWS_IAM"
  http_method = "GET"
  // CF Property(Integration) = {
  //   Type = "AWS_PROXY"
  //   IntegrationHttpMethod = "POST"
  //   Uri = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", aws_lambda_function.function_list_goals.arn, "/invocations"])
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 200
  //     }
  //   ]
  // }
  resource_id = aws_api_gateway_resource.goals_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 200
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_method" "goals_api_request_options" {
  resource_id = aws_api_gateway_resource.goals_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  authorization = "None"
  http_method = "OPTIONS"
  // CF Property(Integration) = {
  //   Type = "MOCK"
  //   IntegrationResponses = [
  //     {
  //       ResponseParameters = {
  //         method.response.header.Access-Control-Allow-Headers = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  //         method.response.header.Access-Control-Allow-Methods = "'GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH'"
  //         method.response.header.Access-Control-Allow-Origin = "'*'"
  //       }
  //       ResponseTemplates = {
  //         application/json = ""
  //       }
  //       StatusCode = "200"
  //     }
  //   ]
  //   PassthroughBehavior = "WHEN_NO_MATCH"
  //   RequestTemplates = {
  //     application/json = "{"statusCode": 200}"
  //   }
  // }
  // CF Property(MethodResponses) = [
  //   {
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //     ResponseParameters = {
  //       method.response.header.Access-Control-Allow-Headers = True
  //       method.response.header.Access-Control-Allow-Methods = True
  //       method.response.header.Access-Control-Allow-Origin = True
  //     }
  //     StatusCode = "200"
  //   }
  // ]
}

resource "aws_api_gateway_method" "goals_api_request_post" {
  authorization = "AWS_IAM"
  http_method = "POST"
  // CF Property(Integration) = {
  //   Type = "AWS_PROXY"
  //   IntegrationHttpMethod = "POST"
  //   Uri = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", aws_lambda_function.function_create_goal.arn, "/invocations"])
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 200
  //     }
  //   ]
  // }
  resource_id = aws_api_gateway_resource.goals_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 200
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_method" "goal_item_api_request_get" {
  authorization = "AWS_IAM"
  http_method = "GET"
  // CF Property(Integration) = {
  //   Type = "AWS_PROXY"
  //   IntegrationHttpMethod = "POST"
  //   Uri = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", aws_lambda_function.function_get_goal.arn, "/invocations"])
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 200
  //       ResponseTemplates = {
  //         application/json = "$input.json('$.body')"
  //       }
  //     }
  //   ]
  // }
  request_parameters = {
    method.request.path.id = True
  }
  resource_id = aws_api_gateway_resource.goal_item_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 200
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_method" "goal_item_api_request_options" {
  resource_id = aws_api_gateway_resource.goal_item_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  authorization = "None"
  http_method = "OPTIONS"
  // CF Property(Integration) = {
  //   Type = "MOCK"
  //   IntegrationResponses = [
  //     {
  //       ResponseParameters = {
  //         method.response.header.Access-Control-Allow-Headers = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  //         method.response.header.Access-Control-Allow-Methods = "'GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH'"
  //         method.response.header.Access-Control-Allow-Origin = "'*'"
  //       }
  //       ResponseTemplates = {
  //         application/json = ""
  //       }
  //       StatusCode = "200"
  //     }
  //   ]
  //   PassthroughBehavior = "WHEN_NO_MATCH"
  //   RequestTemplates = {
  //     application/json = "{"statusCode": 200}"
  //   }
  // }
  // CF Property(MethodResponses) = [
  //   {
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //     ResponseParameters = {
  //       method.response.header.Access-Control-Allow-Headers = True
  //       method.response.header.Access-Control-Allow-Methods = True
  //       method.response.header.Access-Control-Allow-Origin = True
  //     }
  //     StatusCode = "200"
  //   }
  // ]
}

resource "aws_api_gateway_method" "goal_item_api_request_put" {
  authorization = "AWS_IAM"
  http_method = "PUT"
  // CF Property(Integration) = {
  //   Type = "AWS_PROXY"
  //   IntegrationHttpMethod = "POST"
  //   Uri = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", aws_lambda_function.function_update_goal.arn, "/invocations"])
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 200
  //     }
  //   ]
  // }
  request_parameters = {
    method.request.path.id = True
  }
  resource_id = aws_api_gateway_resource.goal_item_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 200
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_method" "goal_item_api_request_delete" {
  authorization = "AWS_IAM"
  http_method = "DELETE"
  // CF Property(Integration) = {
  //   Type = "AWS_PROXY"
  //   IntegrationHttpMethod = "POST"
  //   Uri = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", aws_lambda_function.function_delete_goal.arn, "/invocations"])
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 200
  //     }
  //   ]
  // }
  request_parameters = {
    method.request.path.id = True
  }
  resource_id = aws_api_gateway_resource.goal_item_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 200
  //     ResponseModels = {
  //       application/json = "Empty"
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_resource" "goals_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  parent_id = aws_api_gateway_rest_api.app_api.root_resource_id
  path_part = "goals"
}

resource "aws_api_gateway_resource" "goal_item_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  parent_id = aws_api_gateway_resource.goals_api_resource.id
  path_part = "{id}"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  authorizer_result_ttl_in_seconds = 300
  identity_source = "method.request.header.Authorization"
  name = "CognitoDefaultUserPoolAuthorizer"
  provider_arns = [
    aws_cognito_user_pool.user_pool.arn
  ]
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  type = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  description = "Prod deployment for API"
  rest_api_id = aws_api_gateway_rest_api.app_api.arn
  stage_name = "prod"
}

resource "aws_iam_role" "sns_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "cognito-idp.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "CognitoSNSPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = "sns:publish"
            Resource = "*"
          }
        ]
      }
    }
  ]
}

resource "aws_cognito_user_pool" "user_pool" {
  name = var.project_name
  username_attributes = [
    "email"
  ]
  admin_create_user_config = {
    AllowAdminCreateUserOnly = False
    InviteMessageTemplate = {
      EmailMessage = "Your username is {username} and temporary password is {####}. "
      EmailSubject = "Your temporary password"
      SMSMessage = "Your username is {username} and temporary password is {####}."
    }
    UnusedAccountValidityDays = 7
  }
  // CF Property(Policies) = {
  //   PasswordPolicy = {
  //     MinimumLength = 8
  //     RequireLowercase = False
  //     RequireNumbers = False
  //     RequireSymbols = False
  //     RequireUppercase = False
  //   }
  // }
  auto_verified_attributes = [
    "email"
  ]
  email_verification_message = "Here is your verification code: {####}"
  email_verification_subject = "Your verification code"
  schema = [
    {
      name = "email"
      attribute_data_type = "String"
      mutable = False
      required = True
    }
  ]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name = var.project_name
  generate_secret = False
  user_pool_id = aws_cognito_user_pool.user_pool.arn
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "${var.project_name}Identity"
  allow_unauthenticated_identities = True
  cognito_identity_providers = [
    {
      client_id = aws_cognito_user_pool_client.user_pool_client.client_secret
      provider_name = aws_cognito_user_pool.user_pool.name
    }
  ]
}

resource "aws_iam_role" "cognito_un_authorized_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ]
        Condition = {
          StringEquals = {
            cognito-identity.amazonaws.com:aud = aws_cognito_identity_pool.identity_pool.id
          }
          ForAnyValue:StringLike = {
            cognito-identity.amazonaws.com:amr = "unauthenticated"
          }
        }
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "CognitoUnauthorizedPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "mobileanalytics:PutEvents",
              "cognito-sync:*"
            ]
            Resource = "*"
          }
        ]
      }
    }
  ]
}

resource "aws_iam_role" "cognito_authorized_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ]
        Condition = {
          StringEquals = {
            cognito-identity.amazonaws.com:aud = aws_cognito_identity_pool.identity_pool.id
          }
          ForAnyValue:StringLike = {
            cognito-identity.amazonaws.com:amr = "authenticated"
          }
        }
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "CognitoAuthorizedPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "mobileanalytics:PutEvents",
              "cognito-sync:*",
              "cognito-identity:*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "execute-api:Invoke"
            ]
            Resource = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.app_api.arn, "/*"])
          }
        ]
      }
    }
  ]
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_role_mapping" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    authenticated = aws_iam_role.cognito_authorized_role.arn
    unauthenticated = aws_iam_role.cognito_un_authorized_role.arn
  }
}

resource "aws_codecommit_repository" "assets_code_repository" {
  description = "Code repository for web application"
  repository_name = "${var.project_name}-WebAssets"
}

resource "aws_s3_bucket" "assets_bucket" {
  // CF Property(MetricsConfigurations) = [
  //   {
  //     Id = "EntireBucket"
  //   }
  // ]
  website {
    index_document = "index.html"
  }
  acl = "private"
}

resource "aws_s3_bucket_policy" "assets_bucket_policy" {
  bucket = aws_s3_bucket.assets_bucket.id
  policy = jsonencode({
      Statement = [
        {
          Action = "s3:GetObject"
          Effect = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.assets_bucket.id}/*"
          Principal = {
            AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.assets_bucket_origin_access_identity.id}"
          }
        }
      ]
    }
  )
}

resource "aws_cloudfront_origin_access_identity" "assets_bucket_origin_access_identity" {
  // CF Property(CloudFrontOriginAccessIdentityConfig) = {
  //   Comment = "OriginAccessIdentity for ${aws_s3_bucket.assets_bucket.id}"
  // }
}

resource "aws_cloudfront_distribution" "assets_cdn" {
  // CF Property(DistributionConfig) = {
  //   Enabled = True
  //   Comment = "CDN for ${aws_s3_bucket.assets_bucket.id}"
  //   DefaultRootObject = "index.html"
  //   Origins = [
  //     {
  //       DomainName = join("", ["${aws_s3_bucket.assets_bucket.id}.s3", local.IADRegion ? "" : "-${data.aws_region.current.name}", ".amazonaws.com"])
  //       Id = "S3"
  //       S3OriginConfig = {
  //         OriginAccessIdentity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.assets_bucket_origin_access_identity.id}"
  //       }
  //     }
  //   ]
  //   DefaultCacheBehavior = {
  //     TargetOriginId = "S3"
  //     ViewerProtocolPolicy = "https-only"
  //     ForwardedValues = {
  //       QueryString = "false"
  //     }
  //   }
  // }
}

resource "aws_iam_role" "code_build_role" {
  assume_role_policy = {
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "codebuild.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "codebuild-policy"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:GetBucketVersioning"
            ]
            Resource = [
              join("", [aws_s3_bucket.assets_bucket.arn, "/*"]),
              join("", [aws_s3_bucket.pipeline_artifacts_bucket.arn, "/*"])
            ]
            Effect = "Allow"
          }
        ]
      }
    },
    {
      PolicyName = "codebuild-logs"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:CreateLogGroup",
              "cloudfront:CreateInvalidation"
            ]
            Resource = "*"
            Effect = "Allow"
          }
        ]
      }
    }
  ]
  path = "/"
}

resource "aws_iam_role" "code_pipeline_role" {
  assume_role_policy = {
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "codepipeline.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "codecommit-for-codepipeline"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "codecommit:GetBranch",
              "codecommit:GetCommit",
              "codecommit:UploadArchive",
              "codecommit:GetUploadArchiveStatus",
              "codecommit:CancelUploadArchive"
            ]
            Resource = aws_codecommit_repository.assets_code_repository.arn
            Effect = "Allow"
          }
        ]
      }
    },
    {
      PolicyName = "artifacts-for-pipeline"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "s3:PutObject",
              "s3:GetObject"
            ]
            Resource = join("", [aws_s3_bucket.pipeline_artifacts_bucket.arn, "/*"])
            Effect = "Allow"
          }
        ]
      }
    },
    {
      PolicyName = "codebuild-for-pipeline"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "codebuild:BatchGetBuilds",
              "codebuild:StartBuild"
            ]
            Resource = aws_codebuild_project.code_build_project.arn
            Effect = "Allow"
          }
        ]
      }
    }
  ]
  path = "/"
}

resource "aws_s3_bucket" "pipeline_artifacts_bucket" {
  acl = "private"
}

resource "aws_codebuild_project" "code_build_project" {
  artifacts {
    type = "CODEPIPELINE"
  }
  description = "Building stage for ${var.project_name}."
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    environment_variable = [
      {
        Name = "S3_BUCKET"
        Value = aws_s3_bucket.pipeline_artifacts_bucket.id
      }
    ]
    image = "aws/codebuild/standard:2.0"
    type = "LINUX_CONTAINER"
  }
  name = "${var.project_name}-build"
  service_role = aws_iam_role.code_build_role.arn
  source {
    type = "CODEPIPELINE"
    buildspec = "version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 10
  pre_build:
    commands:
      - echo Installing NPM dependencies...
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    commands:
      - echo Uploading to AssetsBucket 
      - aws s3 cp --recursive ./build s3://${aws_s3_bucket.assets_bucket.id}/ 
      - aws s3 cp --cache-control="max-age=0, no-cache, no-store, must-revalidate" ./build/service-worker.js s3://${aws_s3_bucket.assets_bucket.id}/
      - aws s3 cp --cache-control="max-age=0, no-cache, no-store, must-revalidate" ./build/index.html s3://${aws_s3_bucket.assets_bucket.id}/
      - aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.assets_cdn.id} --paths /index.html /service-worker.js

artifacts:
  files:
    - '**/*'
  base-directory: build        
"
  }
  // CF Property(TimeoutInMinutes) = 5
  tags = {
    app-name = var.project_name
  }
}

resource "aws_datapipeline_pipeline" "assets_code_pipeline" {
  name = "${var.project_name}-Assets-Pipeline"
  // CF Property(RoleArn) = aws_iam_role.code_pipeline_role.arn
  // CF Property(ArtifactStore) = {
  //   Location = aws_s3_bucket.pipeline_artifacts_bucket.id
  //   Type = "S3"
  // }
  tags = [
    {
      Name = "Source"
      Actions = [
        {
          Name = "Source"
          InputArtifacts = [
          ]
          ActionTypeId = {
            Version = "1"
            Category = "Source"
            Owner = "AWS"
            Provider = "CodeCommit"
          }
          Configuration = {
            BranchName = "master"
            RepositoryName = "${var.project_name}-WebAssets"
          }
          OutputArtifacts = [
            {
              Name = "${var.project_name}-SourceArtifact"
            }
          ]
        }
      ]
    },
    {
      Name = "Build"
      Actions = [
        {
          Name = "build-and-deploy"
          InputArtifacts = [
            {
              Name = "${var.project_name}-SourceArtifact"
            }
          ]
          ActionTypeId = {
            Category = "Build"
            Owner = "AWS"
            Version = "1"
            Provider = "CodeBuild"
          }
          OutputArtifacts = [
            {
              Name = "${var.project_name}-BuildArtifact"
            }
          ]
          Configuration = {
            ProjectName = "${var.project_name}-build"
          }
          RunOrder = 1
        }
      ]
    }
  ]
}

resource "aws_lambda_function" "seeder_function" {
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["SeederFunctionBucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["SeederFunctionCode"]
  }
  description = "CodeCommit repository seeder"
  handler = "seeder.SeedRepositoryHandler"
  memory_size = 3008
  role = aws_iam_role.seeder_role.arn
  runtime = "java8"
  timeout = 900
}

resource "aws_lambda_function" "update_config_function" {
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["UpdateConfigCode"]
  }
  description = "Update config for CodeCommit repository"
  handler = "index.handler"
  role = aws_iam_role.seeder_role.arn
  runtime = "nodejs12.x"
  timeout = 300
  environment {
    variables = {
      API_URL = "https://${aws_api_gateway_rest_api.app_api.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod"
      BRANCH_NAME = "master"
      REGION = data.aws_region.current.name
      REPOSITORY_NAME = "${var.project_name}-WebAssets"
      USER_POOL_ID = aws_cognito_user_pool.user_pool.arn
      APP_CLIENT_ID = aws_cognito_user_pool_client.user_pool_client.client_secret
      IDENTITY_POOL_ID = aws_cognito_identity_pool.identity_pool.id
    }
  }
}

resource "aws_iam_role" "seeder_role" {
  assume_role_policy = {
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
    Version = "2012-10-17"
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  force_detach_policies = [
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "codecommit:GetRepository",
              "codecommit:GitPush",
              "codecommit:GetBranch",
              "codecommit:PutFile"
            ]
            Effect = "Allow"
            Resource = aws_codecommit_repository.assets_code_repository.arn
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "SeederRolePolicy"
    },
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "logs:*"
            ]
            Effect = "Allow"
            Resource = "arn:aws:logs:*:*:*"
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "LogsPolicy"
    }
  ]
}

resource "aws_sagemaker_code_repository" "repository_seeder" {
  // CF Property(ServiceToken) = aws_lambda_function.seeder_function.arn
  // CF Property(sourceUrl) = local.mappings["Constants"]["AppKeys"]["SeedRepository"]
  code_repository_name = "${var.project_name}-WebAssets"
  // CF Property(targetRepositoryRegion) = "${AWS::Region}"
}

resource "aws_ram_resource_association" "repository_updater" {
  // CF Property(ServiceToken) = aws_lambda_function.update_config_function.arn
  // CF Property(ParameterOne) = "Parameter to pass into Custom Lambda Function"
  // CF Property(DependsOn) = "UpdateConfigFunction"
}

resource "aws_iam_role" "bucket_cleanup_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  force_detach_policies = [
    {
      PolicyName = "BucketCleanupPolicy"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "s3:List*",
              "s3:DeleteObject"
            ]
            Effect = "Allow"
            Resource = [
              aws_s3_bucket.assets_bucket.arn,
              aws_s3_bucket.pipeline_artifacts_bucket.arn,
              join("", [aws_s3_bucket.assets_bucket.arn, "/*"]),
              join("", [aws_s3_bucket.pipeline_artifacts_bucket.arn, "/*"])
            ]
          }
        ]
        Version = "2012-10-17"
      }
    }
  ]
}

resource "aws_lambda_layer_version" "python_lambda_layer" {
  compatible_runtimes = [
    "python3.7",
    "python3.6"
  ]
  // CF Property(Content) = {
  //   S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
  //   S3Key = local.mappings["Constants"]["S3Keys"]["PythonLambdaLayer"]
  // }
}

resource "aws_lambda_function" "bucket_cleanup_function" {
  function_name = "${var.project_name}-BucketCleanup"
  description = "Cleanup S3 buckets when deleting stack"
  handler = "index.handler"
  memory_size = 256
  role = aws_iam_role.bucket_cleanup_role.arn
  runtime = "python3.7"
  timeout = 30
  layers = [
    aws_lambda_layer_version.python_lambda_layer.arn
  ]
  code_signing_config_arn = {
    S3Bucket = local.mappings["S3Buckets"][data.aws_region.current.name]["Bucket"]
    S3Key = local.mappings["Constants"]["S3Keys"]["DeleteBucketsCode"]
  }
}

resource "aws_ram_resource_association" "delete_buckets_objects" {
  // CF Property(ServiceToken) = aws_lambda_function.bucket_cleanup_function.arn
  // CF Property(BucketNames) = [
  //   aws_s3_bucket.assets_bucket.id,
  //   aws_s3_bucket.pipeline_artifacts_bucket.id
  // ]
  // CF Property(DependsOn) = [
  //   "BucketCleanupFunction",
  //   "BucketCleanupRole"
  // ]
}

