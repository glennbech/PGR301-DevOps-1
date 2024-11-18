variable "bucket_name" {
  description = "S3 bucket for storing generated images"
  type        = string
  default     = "pgr301-couch-explorers"
}

variable "lambda_role_name" {
  description = "IAM Role for Lambda function"
  type        = string
  default     = "ha_lambda_role"
}

variable "sqs_queue_name" {
  description = "Name of SQS queue for image generation"
  type        = string
  default     = "image_generation_queue"
}

variable "candidate_number" {
  description = "Candidate number to prefix resources"
  type        = string
  default     = "104"
}
