data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "aws_security_group" "eks_msk" {
  name   = "${var.cluster_name}-msk"
  vpc_id = module.vpc.vpc_id

}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.20"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }
  manage_aws_auth_configmap = true


  aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "admintf"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      username = "adminawsroot"
      groups   = ["system:masters"]
    },
  ]
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = [var.humio_instance_type]

    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = [aws_security_group.eks_msk.id]
  }

  eks_managed_node_groups = {
    humio = {
      min_size     = var.humio_instance_count - 1
      max_size     = var.humio_instance_count + 2
      desired_size = var.humio_instance_count

      labels = {
        Environment = "Production"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }


      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
      pre_bootstrap_user_data = templatefile("${path.module}/${var.user_data_script}", { humio_data_dir = var.humio_data_dir, humio_data_dir_owner_uuid = var.humio_data_dir_owner_uuid })
    }
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}
