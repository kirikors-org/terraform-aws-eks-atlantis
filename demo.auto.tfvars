region = "eu-north-1"

availability_zones = ["eu-north-1a", "eu-north-1b"]

namespace = "kk"

stage = "dev"

name = "atlantis"

vpc_base_cidr = "172.16.0.0/16"

subnet_type = "public"

max_subnets = 2

oidc_provider_enabled = false

kubernetes_version = "1.15"

enabled_cluster_log_types = ["audit"]

cluster_log_retention_period = 7

instance_type = "t3.micro"

max_size = 2

min_size = 1

local_exec_interpreter = ["sh", "-c"]

atlantis_github_repo = "github.com/kirikors-org/terraform-aws-eks-atlantis"
