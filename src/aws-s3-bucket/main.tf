provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "abhishek" {
  ami           = "ami-02d26659fd82cf299"         # Ensure this AMI exists in us-east-1
  instance_type = "t2.micro"
  subnet_id     = "subnet-082cf53e16ada641f"      # Ensure this subnet is in us-east-1
  tags = {
    Name = "Abhishek-Instance"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-bakcend-bucket1"            # Match this with your manually created bucket
  tags = {
    Environment = "Terraform-Backend"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "Terraform-Lock"
  }
}