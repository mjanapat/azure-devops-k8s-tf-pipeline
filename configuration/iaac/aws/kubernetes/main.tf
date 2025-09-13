terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12"
    }
  }

  backend "s3" {
    bucket = "terraform-bakcend-bucket1"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.0"

  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.24"
  vpc_id          = aws_default_vpc.default.id
  subnet_ids      = data.aws_subnet_ids.default_subnets.ids

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      desired_size    = 3
      max_size        = 5
      min_size        = 3
      instance_types  = ["t2.micro"]
    }
  }

  tags = {
    Environment = "Dev"
    Owner       = "Maruthi"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_cluster_role_binding" "ci_cd_access" {
  metadata {
    name = "fabric8-rbac"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}
