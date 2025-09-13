provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "abhishek" {
  instance_type = "t2.micro"
  ami = "ami-02d26659fd82cf299" # change this
  subnet_id = "subnet-082cf53e16ada641f" # change this
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-bakcend-bucket1" # change this
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}