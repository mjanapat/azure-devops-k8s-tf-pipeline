provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "paxis" {
  ami           = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0db4b038e3e34bb51"
  tags = {
    Name = "eksmaster-Instance"
  }
}

# S3 Bucket for Terraform Backend
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-bakcend-bucket1"
  tags = {
    Environment = "Terraform-Backend"
  }
}

# DynamoDB Table for State Locking
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

# Call your custom EKS module
module "eks_cluster" {
  source          = "./modules/eks_cluster"
  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.24"
  subnet_ids      = [
    "subnet-0db4b038e3e34bb51",
    "subnet-093a6749a1cd59553" # Replace with your actual subnet ID
  ]
}
