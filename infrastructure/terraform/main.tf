terraform {
  backend "s3" {
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "sail-tech"
      CodeSource  = "tbd"
      Managed     = "Terraform"
    }
  }
}

locals {
  python_requests_layer_arn = "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-requests:11"
}