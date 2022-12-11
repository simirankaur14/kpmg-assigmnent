#################### Lambda Function #################
resource "aws_lambda_function" "test_lambda" {
  for_each      = { for key, value in var.lambda_block : key => value }
  filename      = each.value.filename
  function_name = each.value.function_name
  role          = aws_iam_role.logs_role.arn
  handler       = each.value.handler
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout 
  runtime       = each.value.runtime

   tags = {
    Name = each.value.function_name
    Environment = "test"
     }
}


################ Lambda cloudwatch access #################

resource "aws_iam_role_policy" "logs_role" {
  name = "lambdatocloudwatch"
  role = aws_iam_role.logs_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
      "Effect": "Allow"
    },
    ]
    })
}
resource "aws_iam_role" "logs_role" {
  name = "lambdatocloudwatch"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
################### Apigateway ######################

resource "aws_api_gateway_rest_api" "api" {
  name = var.name_api
  description = var.description_api
  depends_on = [ aws_lambda_function.test_lambda
  ]
}

resource "aws_api_gateway_resource" "myresource" {
 for_each      = { for key, value in var.api_gateway_block : key => value }
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value.path_part
  rest_api_id = aws_api_gateway_rest_api.api.id
    depends_on = [ aws_api_gateway_rest_api.api
  ]
}

resource "aws_api_gateway_method" "mymethod" {
  for_each      = { for key, value in var.api_gateway_block : key => value }
  authorization = "NONE"
  http_method   = each.value.http_method
  resource_id   = aws_api_gateway_resource.myresource[each.key].id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "integration" {
  for_each      = { for key, value in var.api_gateway_integration_block : key => value }
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.mymethod[each.key].http_method
  resource_id             = aws_api_gateway_resource.myresource[each.key].id
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  uri                     = aws_lambda_function.test_lambda[each.value.lambda_ref_name].invoke_arn
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  for_each      = { for key, value in var.api_gateway_integration_block : key => value }
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda[each.value.lambda_ref_name].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn =  "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each      = { for key, value in var.api_gateway_block : key => value }
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.myresource[each.key].id
  http_method = aws_api_gateway_method.mymethod[each.key].http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "stage"
  depends_on = [
     aws_api_gateway_deployment.deployment
  ]
}


/*variable "security_group_id" {
  default =  "sg-e23640cb"
}

data "aws_security_group" "selected" {
  id = var.security_group_id
}

resource "aws_mq_configuration" "example" {
  description    = "Example Configuration"
  name           = "example"
  engine_type    = "ActiveMQ"
  engine_version = "5.15.0"

  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
  </plugins>
</broker>
DATA
}
resource "aws_mq_broker" "example" {
  broker_name = "example"

  configuration {
    id       = aws_mq_configuration.example.id
    revision = aws_mq_configuration.example.latest_revision
  }

  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  storage_type       = "efs"
  host_instance_type = "mq.t3.micro"
  publicly_accessible = true
  security_groups    = [data.aws_security_group.selected.id]

  user {
    username = "ExampleUser"
    password = "MindTheGaphellooo"
  }
}
*/








############### S3 Bucket#####################

/*resource "aws_s3_bucket" "bucket-testing" {
  bucket = "bucket-testing-simiran"
  force_destroy = true
  versioning {
    enabled ="true"
  }

  }
*/

##################### CloudWatch ##########################

/*resource "aws_iam_role" "default1" {
  name = "iam_for_lambda_called_from_cloudwatch_logs1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": 
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

resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  #name              = "/aws/lambda/${var.lambda_function_name}"
  name               = "/aws/lambda/newtest1"
 # retention_in_days = 14
}
/*resource "aws_iam_policy" "lambda_logging1" {
  name        = "lambda_logging1"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambdatosqsands31.name
  policy_arn = aws_iam_policy.lambda_logging1.arn
}
*/




/*vpc_config {
       subnet_ids = ["subnet-0e48959ababaf8d19"]
       security_group_ids = ["sg-0bf7031b466f8963b"]
   } 
  /* vpc_config {
       subnet_ids = "subnet-0686092163c636201"
       #security_group_ids = 
   } 
  }

*/


################## SOURCE MAPPING FOR LAMBDA ##############
/*resource "aws_lambda_event_source_mapping" "sqstolambda" {
  depends_on = [
    aws_lambda_function.test_lambda
  ]
  event_source_arn  = aws_sqs_queue.terraform_queue.arn
  function_name     = aws_lambda_function.test_lambda.arn
  enabled          = true
}
 
###################### VPC Endpoint #####################
/*resource "aws_vpc_endpoint" "lambda" {
vpc_id= "vpc-0a6e3d7b742d9f821"
service_name = "com.amazonaws.us-east-1.lambda"
tags = {
Environment = "lambda_endpoint"
}
}
resource "aws_vpc_endpoint_route_table_association" "lambda_vpc_endpoint" {
route_table_id  = "rtb-0ca571a439642ca4b"
  vpc_endpoint_id = aws_vpc_endpoint.lambda.id
}
*/



######################### SQS #########################

/*variable "aws_queue" {
default = ["terraform_queue","my_queue"]
  
}*/


/*resource "aws_sqs_queue" "terraform_queue" {
  #for_each = var.aws_queue
  #name                      = each.value
  name= "terraform-queue"

/*
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
  deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
   maxReceiveCount     = 4
  })
*/
  /*visibility_timeout_seconds = 360
  tags = {
    Environment = "production"
  }
}

####################### SQS POLICY######################

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.terraform_queue.id
  policy = <<POLICY
{
    "Version" :"2012-10-17",
    "Id": "sqspolicy",
    "Statement" : [
      {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:terraform-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket-testing.arn}" 
        }
        }
        },
         {  
        "Sid": "First",
        "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
        "Effect"   : "Allow",
        "Resource": "${aws_sqs_queue.terraform_queue.arn}"
      },
      {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-notification-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket-testing.arn}" }
      }
      }
    ]
    }
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket-testing.id

  queue {
    queue_arn     = aws_sqs_queue.terraform_queue.arn
    events        = ["s3:ObjectCreated:*"]
    #filter_suffix = ".log"
  }
}

####################### Role policy for S3 to access SQS #############################
/*{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}*/

