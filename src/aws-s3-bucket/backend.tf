terraform {
  backend "s3" {
    bucket         = "terraform-bakcend-bucket1"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"  # optional, but still supported
  }
}