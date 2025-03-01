variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
  default     = "104"
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
 default     = "daha025@student.kristiania.no"
}

variable "threshold" {
  description = "Threshold value for triggering CloudWatch alarm on SQS queue age."
  default     = "10"  
  type        = string
}


