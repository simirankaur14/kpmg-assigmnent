#################### Lambda Function #################
resource "aws_lambda_function" "test_lambda" {
  filename      = "./lambda_function.zip"
  function_name = "newtest1"
  role          = aws_iam_role.logs_role.arn
  handler       = "lambda_function.lambda_handler"
  memory_size = 512
  timeout = 360

  runtime = "python3.9"

   tags = {
    Name = "Lamdba_Function"
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
        "logs:PutLogEvents"
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
