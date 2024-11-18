resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
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

resource "aws_lambda_function" "image_lambda" {
  function_name = var.lambda_function_name 
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_sqs.lambda_handler"  # updated handler to matcg lamda_sqs.py
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_sqs.zip"  # using zip-file

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      CANDIDATE_NR = var.candidate_number
    }
  }
  
  timeout = 20

  source_code_hash = filebase64sha256("${path.module}/lambda_sqs.zip")  # using zip-file for hash
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_generation_queue.arn
  function_name    = aws_lambda_function.image_lambda.arn

  batch_size = 10
  enabled    = true

  lifecycle {
    prevent_destroy = true
  }
}

