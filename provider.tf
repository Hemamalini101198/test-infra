terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.30.0"
    }
  }

  #adding s3 bucket for remote state storage
  backend "s3"{
    bucket = "tf-state-eks-test-tf"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }

}
provider "aws" {
  region = "ap-south-1"
}