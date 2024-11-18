terraform {
  required_version = ">= 1.9"  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.74.0"  # AWS provider version
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}