provider "aws" {
  region = var.region
}

# applies strict naming conventions for AWS resources
module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
  enabled     = var.enabled
}

locals {
  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))

  # Unfortunately, most_recent (https://github.com/cloudposse/terraform-aws-eks-workers/blob/34a43c25624a6efb3ba5d2770a601d7cb3c0d391/main.tf#L141)
  # variable does not work as expected, if you are not going to use custom ami you should
  # enforce usage of eks_worker_ami_name_filter variable to set the right kubernetes version for EKS workers,
  # otherwise will be used the first version of Kubernetes supported by AWS (v1.11) for EKS workers but
  # EKS control plane will use the version specified by kubernetes_version variable.
  eks_worker_ami_name_filter = "amazon-eks-node-${var.kubernetes_version}*"
}

# 1. provision AWS resources

# create a VPC
module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  cidr_block = var.vpc_base_cidr
  tags       = local.tags
}

# create public subnets in specified AZs
module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=tags/0.4.0"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  attributes          = var.attributes
  availability_zones  = var.availability_zones
  type                = var.subnet_type
  max_subnets         = var.max_subnets
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  nat_gateway_enabled = false
  tags                = local.tags
}

# fetch current AWS accountId to use for IAM roles designated for K8S
data "aws_caller_identity" "current" {}

# trust relationship for IAM role
data "aws_iam_policy_document" "same_acc_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":root"])]
    }
  }
}

# IAM role to be bound to K8S RBAC admin ClusterRoleBinding
resource "aws_iam_role" "k8s_admin_role" {
  name               = "eks-admin"
  description        = "Grants admin access to K8S cluster on EKS"
  path               = "/k8s/"
  assume_role_policy = data.aws_iam_policy_document.same_acc_assume_role.json
  tags               = local.tags
}

# IAM role to be bound to K8S RBAC read-only ClusterRoleBinding
resource "aws_iam_role" "k8s_read_only_role" {
  name               = "eks-read-only"
  description        = "Grants read-only access to K8S cluster on EKS"
  path               = "/k8s/"
  assume_role_policy = data.aws_iam_policy_document.same_acc_assume_role.json
  tags               = local.tags
}

# create K8S worker nodes backed by EC2
module "eks_workers" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=tags/0.13.0"
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = var.name
  attributes                         = var.attributes
  tags                               = var.tags
  instance_type                      = var.instance_type
  eks_worker_ami_name_filter         = local.eks_worker_ami_name_filter
  vpc_id                             = module.vpc.vpc_id
  subnet_ids                         = values(module.subnets.az_subnet_ids)
  health_check_type                  = var.health_check_type
  min_size                           = var.min_size
  max_size                           = var.max_size
  wait_for_capacity_timeout          = var.wait_for_capacity_timeout
  cluster_name                       = module.label.id
  cluster_endpoint                   = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id          = module.eks_cluster.security_group_id

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
}

# create K8S cluster on EKS
module "eks_cluster" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.22.0"
  namespace                    = var.namespace
  stage                        = var.stage
  name                         = var.name
  attributes                   = var.attributes
  tags                         = var.tags
  region                       = var.region
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = values(module.subnets.az_subnet_ids)
  kubernetes_version           = var.kubernetes_version
  local_exec_interpreter       = var.local_exec_interpreter
  oidc_provider_enabled        = var.oidc_provider_enabled
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  cluster_log_retention_period = var.cluster_log_retention_period
  workers_security_group_ids   = [module.eks_workers.security_group_id]
  workers_role_arns            = [module.eks_workers.workers_role_arn]
  map_additional_iam_roles = [
    {
      rolearn  = aws_iam_role.k8s_admin_role.arn,
      username = "admin",
      groups   = ["system:masters"]
      }, {
      rolearn  = aws_iam_role.k8s_read_only_role.arn,
      username = "read-only",
      groups   = ["readers"]
    }
  ]
}

# 2. provision K8S resources

# get an authentication token to communicate with an EKS cluster
data "aws_eks_cluster" "main" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks_cluster.eks_cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

# create K8S RBAC binding for cluster-wide read-only access
resource "kubernetes_cluster_role_binding" "readers" {
  metadata {
    name = "readers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "readers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# deploy Atlantis application with helm
provider "helm" {
  install_tiller = true
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.main.token
    load_config_file       = false
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "atlantis" {
  name       = var.atlantis_helm_release_name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "atlantis"
  version    = "0.11.1"

  set_sensitive {
    name  = "github.user"
    value = var.atlantis_github_user
  }

  set_sensitive {
    name  = "github.token"
    value = var.atlantis_github_token
  }

  set_sensitive {
    name  = "github.secret"
    value = var.atlantis_github_secret
  }

  set {
    name  = "orgWhitelist"
    value = var.atlantis_github_repo
  }
}
