resource "aws_iam_role" "lambda_exec_role" {
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })

  name = "${var.prefix}_lambda_role"
}

# IAM policy for SQS and S3 access
resource "aws_iam_role_policy" "lambda_sqs_s3_policy" {
  name = "${var.prefix}_LambdaSQSS3Policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::pgr301-couch-explorers/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel"
        ],
        "Resource": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

# lambda function configuration
resource "aws_lambda_function" "sqs_lambda" {
  function_name = "${var.prefix}_sqs_lambda_function"
  runtime       = "python3.9"
  handler       = "lambda_sqs.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "lambda_function_payload.zip"

  environment {
    variables = {
      BUCKET_NAME  = "pgr301-couch-explorers"
      CANDIDATE_NR = var.prefix
    }
  }

  timeout = 30
}

# SQS queue configuration
resource "aws_sqs_queue" "sqs_queue" {
  name = "${var.prefix}-image-queue"
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  batch_size       = 10
  enabled          = true
}