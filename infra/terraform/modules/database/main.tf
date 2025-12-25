terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

variable "db_identifier" {
  type        = string
  description = "Primary database identifier"
}

variable "engine_version" {
  type        = string
  default     = "15.5"
  description = "PostgreSQL engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.m6g.large"
  description = "Instance class for the primary database"
}

variable "allocated_storage" {
  type        = number
  default     = 200
  description = "Initial storage in GiB"
}

variable "max_allocated_storage" {
  type        = number
  default     = 1000
  description = "Maximum storage for autoscaling"
}

variable "db_username" {
  type        = string
  description = "Master username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password"
}

variable "multi_az" {
  type        = bool
  default     = true
}

variable "create_read_replica" {
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-subnets"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.db_identifier}-sg"
  description = "Access to Postgres"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : []
    content {
      description = "VPC ingress"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.db_identifier}-sg" })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.db_identifier}-params"
  family = "postgres15"

  parameter {
    name  = "max_connections"
    value = "500"
  }

  parameter {
    name  = "shared_buffers"
    value = "256MB"
  }

  tags = var.tags
}

resource "aws_db_instance" "primary" {
  identifier              = var.db_identifier
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  backup_retention_period = 7
  multi_az                = var.multi_az
  publicly_accessible     = false
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  parameter_group_name    = aws_db_parameter_group.this.name
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = var.tags
}

resource "aws_db_instance" "replica" {
  count                   = var.create_read_replica ? 1 : 0
  identifier              = "${var.db_identifier}-ro"
  replicate_source_db     = aws_db_instance.primary.id
  instance_class          = var.instance_class
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = var.tags
}

output "primary_endpoint" {
  value       = aws_db_instance.primary.address
  description = "DNS of the primary writer instance"
}

output "reader_endpoint" {
  value       = try(aws_db_instance.replica[0].address, aws_db_instance.primary.address)
  description = "DNS of the read replica (or writer if replica disabled)"
}

output "security_group_id" {
  value       = aws_security_group.db.id
  description = "Security group protecting the database"
}
