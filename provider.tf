terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}

provider "aws" {
    shared_config_files      = ["/home/unthinkable-lap-0258/.aws/config"]
    shared_credentials_files = ["/home/unthinkable-lap-0258/.aws/credentials"]
    region = "us-east-1"
    profile = "default"
}