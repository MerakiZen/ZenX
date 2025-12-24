terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR range for the VPC"
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability zones to span"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.10.0.0/20", "10.10.16.0/20"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.10.32.0/20", "10.10.48.0/20"]
  description = "CIDR blocks for private subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to provision a managed NAT gateway"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to networking resources"
}

locals {
  az_count   = length(var.azs)
  env_prefix = coalesce(try(var.tags["env"], null), "zenx")
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.azs, tonumber(each.key) % local.az_count)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.azs, tonumber(each.key) % local.az_count)

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  count      = var.enable_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, { Name = "${local.env_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = element(values(aws_subnet.public)[*].id, 0)

  tags = merge(var.tags, { Name = "${local.env_prefix}-nat" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? local.az_count : 0
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.env_prefix}-private-rt-${count.index}"
  })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? local.az_count : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id = var.enable_nat_gateway ?
    element(aws_route_table.private[*].id, tonumber(each.key) % local.az_count) :
    aws_route_table.public.id
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "Identifier of the created VPC"
}

output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "Identifiers of public subnets"
}

output "private_subnet_ids" {
  value       = values(aws_subnet.private)[*].id
  description = "Identifiers of private subnets"
}

output "vpc_cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "CIDR block of the VPC"
}
