terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster"
}

variable "region" {
  type        = string
  description = "Cloud region"
}

variable "cluster_version" {
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  type        = string
}

variable "private_subnet_ids" {
  type        = list(string)
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.large"]
}

variable "desired_capacity" {
  type        = number
  default     = 3
}

variable "min_size" {
  type        = number
  default     = 2
}

variable "max_size" {
  type        = number
  default     = 6
}

variable "tags" {
  type        = map(string)
  default     = {}
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  region = var.region

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : var.private_subnet_ids

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_capacity
      capacity_type  = "ON_DEMAND"
      labels = {
        role = "general"
      }
      tags = var.tags
    }
  }

  tags = var.tags
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the created EKS cluster"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "API server endpoint"
}

output "cluster_ca_certificate" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate authority data"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "OIDC provider ARN for IRSA"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security group attached to the control plane"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "Security group applied to managed nodes"
}

output "cluster_context" {
  description = "Kubeconfig context name"
  value       = module.eks.cluster_name
}
