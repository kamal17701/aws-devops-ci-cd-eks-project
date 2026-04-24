terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  # Remote state stored in S3 with DynamoDB locking
  # Create the bucket and table manually once before running terraform init
  backend "s3" {
    bucket         = "kamal-terraform-state-bucket"
    key            = "eks-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "kamal-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kamal-devops-demo"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
