terraform {
  backend "s3" {
    bucket = "terraform-bakcend-bucket1"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.0"  # Use latest stable version

  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.24"
  vpc_id          = "vpc-0e1c1265410fcb664"
  subnet_ids      = ["subnet-0db4b038e3e34bb51", "subnet-093a6749a1cd59553"]

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      desired_size    = 3
      max_size        = 5
      min_size        = 3
      instance_types  = ["t2.micro"]
    }
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
  version                = "~> 2.12"
}

resource "kubernetes_cluster_role_binding" "example" {
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
