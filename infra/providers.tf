terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }


  # Si on met ca en place faut soit remplacer par notre bucket iimtib62673 soit donner les permissions a ce bucket la dans S3
  # backend "s3" {
  #   bucket         = "terraform-backend-terraformbackends3bucket-kmf8fwf9q4zr"
  #   key            = "infra/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "terraform-backend-TerraformBackendDynamoDBTable-1H2S07OFDUIEQ"
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# # Create a VPC
# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }