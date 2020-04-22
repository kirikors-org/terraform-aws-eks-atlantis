# global resource creation toggle

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

# AWS common parameters

variable "region" {
  type        = string
  description = "AWS region to create the resources in"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones (e.g. `['us-east-1a', 'us-east-1b', 'us-east-1c']`)"
}

# naming conventions and tags

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "additional_tag_map" {
  type        = map(string)
  default     = {}
  description = "Additional tags for appending to each tag map"
}

# VPC-related parameters

variable "vpc_base_cidr" {
  type        = string
  description = "VPC base CIDR"
}

variable "subnet_type" {
  type        = string
  default     = "private"
  description = "Type of subnets to create (`private` or `public`)"
}

variable "max_subnets" {
  type        = number
  default     = 2
  description = "Maximum number of subnets that can be created. The variable is used for CIDR blocks calculation"
}

# parameters for the K8S cluster on EKS

variable "kubernetes_version" {
  type        = string
  default     = "1.15"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "oidc_provider_enabled" {
  type        = bool
  default     = true
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using `kiam` or `kube2iam`. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "local_exec_interpreter" {
  type        = list(string)
  default     = ["/bin/sh", "-c"]
  description = "shell to use for local_exec"
}

# parameters for K8S worker nodes

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
  default     = "10m"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to launch"
}

variable "max_size" {
  type        = number
  description = "The maximum size of the auto-scaling group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the auto-scaling group"
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  default     = 90
  description = "The value against which the specified statistic is compared"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  default     = 10
  description = "The value against which the specified statistic is compared"
}

variable "health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
  default     = "EC2"
}

# parameters for Atlantis and target GitHub repo

variable "atlantis_helm_release_name" {
  type        = string
  description = "Helm release name for Atlantis"
  default     = "atlantis"
}

variable "atlantis_github_repo_org" {
  type        = string
  description = "GitHub organization for Atlantis target repo whitelist"
}

variable "atlantis_github_repo_name" {
  type        = string
  description = "GitHub repository name for Atlantis target repo whitelist"
}

variable "atlantis_github_user" {
  type        = string
  description = "GitHub user for Atlantis bot"
}

variable "atlantis_github_token" {
  type        = string
  description = "GitHub token for the Atlantis bot user"
}

variable "atlantis_github_secret" {
  type        = string
  description = "Webhook secret for the GitHub repository monitored by Atlantis"
}

variable "atlantis_tfe_token" {
  type        = string
  description = "Terraform cloud token for Atlantis"
}
