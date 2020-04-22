Deploys [Atlantis application](https://www.runatlantis.io) on AWS EKS (backed by EC2) using Terraform and Helm.

# Dependencies
Uses Open Source terraform modules from [CloudPosse](https://cloudposse.com):
1. [terraform-null-label](https://github.com/cloudposse/terraform-null-label) to generate consistent names and tags for resources
2. [terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc.git) to create a VPC
3. [terraform-aws-multi-az-subnets](https://github.com/cloudposse/terraform-aws-multi-az-subnets.git) to create 2 subnets in different availability availability_zones
4. [terraform-aws-eks-cluster](https://github.com/cloudposse/terraform-aws-eks-cluster.git) to create a K8S cluster on EKS
5. [terraform-aws-eks-workers](https://github.com/cloudposse/terraform-aws-eks-workers.git) to create K8S worker nodes (EC2) in an auto-scaling group

Atlantis is exposed via K8S ingress using [AWS ALB ingress controller](https://github.com/iplabs/terraform-kubernetes-alb-ingress-controller) from iplabs.

# AWS resources
Creates the following AWS resources:
1. VPC with Internet Gateway
2. 2 public subnets in different availability zones
3. EKS cluster
4. Worker auto-scaling group with min 1...max 2 worker EC2 nodes
5. 2 IAM roles for K8S RBAC: eks-admin (with admin access) and eks-read-only (with read-only access)

# Atlantis application
Deploys [Atlantis application](https://www.runatlantis.io) in the K8S cluster via Helm.

Configures a webhook in the target GitHub repository for Atlantis.
