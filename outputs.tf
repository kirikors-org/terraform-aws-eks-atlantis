output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "vpc_igw_id" {
  value       = module.vpc.igw_id
  description = "The ID of the Internet Gateway"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "vpc_main_route_table_id" {
  value       = module.vpc.vpc_main_route_table_id
  description = "The ID of the main route table associated with this VPC"
}

output "vpc_public_subnet_cidrs" {
  value       = module.subnets.public_subnet_ids
  description = "Public subnet IDs"
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster Security Group"
  value       = module.eks_cluster.security_group_id
}

output "eks_cluster_security_group_arn" {
  description = "ARN of the EKS cluster Security Group"
  value       = module.eks_cluster.security_group_arn
}

output "eks_cluster_security_group_name" {
  description = "Name of the EKS cluster Security Group"
  value       = module.eks_cluster.security_group_name
}

output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = module.eks_cluster.eks_cluster_id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_cluster.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = module.eks_cluster.eks_cluster_endpoint
}

output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = module.eks_cluster.eks_cluster_version
}

output "eks_cluster_identity_oidc_issuer" {
  description = "The OIDC Identity issuer for the cluster"
  value       = module.eks_cluster.eks_cluster_identity_oidc_issuer
}

output "eks_cluster_managed_security_group_id" {
  description = "Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads"
  value       = module.eks_cluster.eks_cluster_managed_security_group_id
}

output "workers_launch_template_id" {
  description = "The ID of the launch template"
  value       = module.eks_workers.launch_template_id
}

output "workers_launch_template_arn" {
  description = "ARN of the launch template"
  value       = module.eks_workers.launch_template_arn
}

output "autoscaling_group_id" {
  description = "The AutoScaling Group ID"
  value       = module.eks_workers.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The AutoScaling Group name"
  value       = module.eks_workers.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the AutoScaling Group"
  value       = module.eks_workers.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the AutoScaling Group"
  value       = module.eks_workers.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the AutoScaling Group"
  value       = module.eks_workers.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.eks_workers.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.eks_workers.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.eks_workers.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.eks_workers.autoscaling_group_health_check_type
}

output "workers_security_group_id" {
  description = "ID of the worker nodes Security Group"
  value       = module.eks_workers.security_group_id
}

output "workers_security_group_arn" {
  description = "ARN of the worker nodes Security Group"
  value       = module.eks_workers.security_group_arn
}

output "workers_security_group_name" {
  description = "Name of the worker nodes Security Group"
  value       = module.eks_workers.security_group_name
}

output "workers_role_arn" {
  description = "ARN of the worker nodes IAM role"
  value       = module.eks_workers.workers_role_arn
}

output "atlantis_alb_hostname" {
  description = "Hostname of the ALB exposing Atlantis via k8s ingress"
  value       = data.aws_lb.alb_ingress.dns_name
}

output "atlantis_webhooks_endpoint" {
  description = "Endpoint for Atlantis webhooks"
  value       = join("", ["http://", data.aws_lb.alb_ingress.dns_name, "/events"])
}
