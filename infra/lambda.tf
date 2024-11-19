resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sqs_s3_policy" {
  name = "${var.prefix}_lambda_sqs_s3_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "sqs_lambda" {
  function_name = "${var.prefix}_sqs_lambda_function"
  runtime       = "python3.9"
  handler       = "lambda_sqs.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "lambda_sqs.zip"

  environment {
    variables = {
      BUCKET_NAME  = var.bucket_name
      CANDIDATE_NR = var.prefix
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "${var.prefix}-${var.sqs_queue_name}"
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  batch_size       = 10
  enabled          = true
}
