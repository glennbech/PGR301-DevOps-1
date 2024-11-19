variable "prefix" {
  description = "Unique prefix for all resource names"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for storing data"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "image_generation_queue"
}
