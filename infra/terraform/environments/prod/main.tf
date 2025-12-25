terraform {
  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

locals {
  tags = {
    project = "zenx"
    env     = "prod"
  }
}

module "networking" {
  source               = "../../modules/networking"
  vpc_cidr             = "10.20.0.0/16"
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  tags                 = local.tags
}

module "kubernetes" {
  source             = "../../modules/kubernetes"
  cluster_name       = "zenx-prod-eks"
  cluster_version    = var.cluster_version
  region             = var.region
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  node_instance_types = ["m6g.xlarge"]
  desired_capacity    = 6
  min_size            = 4
  max_size            = 10
  tags                = local.tags
}

data "aws_eks_cluster" "this" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.kubernetes.cluster_name
}

module "database" {
  source                 = "../../modules/database"
  db_identifier          = "zenx-prod-db"
  instance_class         = "db.r6g.xlarge"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  db_username            = var.db_username
  db_password            = var.db_password
  allowed_cidr_blocks    = [module.networking.vpc_cidr_block]
  allocated_storage      = 500
  max_allocated_storage  = 2000
  create_read_replica    = true
  tags                   = local.tags
}

module "monitoring" {
  source                   = "../../modules/monitoring"
  cluster_endpoint         = module.kubernetes.cluster_endpoint
  cluster_ca_certificate   = module.kubernetes.cluster_ca_certificate
  cluster_auth_token       = data.aws_eks_cluster_auth.this.token
  grafana_admin_password   = var.grafana_admin_password
  prometheus_retention     = "30d"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.64.0/20", "10.20.80.0/20", "10.20.96.0/20"]
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
