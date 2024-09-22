# Terraform Settings Block
terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.37"
    }
  }

  backend "s3" {
    bucket  = "s3-bucket-name"
    key     = "tfstate-file.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

# Provider Block
provider "aws" {
  region = "ap-southeast-1"
}
