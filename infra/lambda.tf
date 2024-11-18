resource "aws_lambda_function" "image_lambda" {
  function_name = "image_lambda_104"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_sqs.zip"

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.image_queue.id
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.image_lambda.arn
}