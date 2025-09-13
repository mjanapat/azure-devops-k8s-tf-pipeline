terraform {
  backend "s3" {
    bucket         = "terraform-bakcend-bucket2" # change this
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}