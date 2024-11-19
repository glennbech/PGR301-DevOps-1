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
