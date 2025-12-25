terraform {
  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

locals {
  tags = {
    project = "zenx"
    env     = "dev"
  }
}

module "networking" {
  source                = "../../modules/networking"
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  enable_nat_gateway    = true
  tags                  = local.tags
}

module "kubernetes" {
  source             = "../../modules/kubernetes"
  cluster_name       = "zenx-dev-eks"
  cluster_version    = var.cluster_version
  region             = var.region
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  node_instance_types = ["t3.large"]
  desired_capacity    = 3
  min_size            = 2
  max_size            = 4
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
  db_identifier          = "zenx-dev-db"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  db_username            = var.db_username
  db_password            = var.db_password
  allowed_cidr_blocks    = [module.networking.vpc_cidr_block]
  allocated_storage      = 100
  max_allocated_storage  = 400
  create_read_replica    = false
  tags                   = local.tags
}

module "monitoring" {
  source                   = "../../modules/monitoring"
  cluster_endpoint         = module.kubernetes.cluster_endpoint
  cluster_ca_certificate   = module.kubernetes.cluster_ca_certificate
  cluster_auth_token       = data.aws_eks_cluster_auth.this.token
  grafana_admin_password   = var.grafana_admin_password
  observability_namespace  = "observability"
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
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.0.0/20", "10.10.16.0/20"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.32.0/20", "10.10.48.0/20"]
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
