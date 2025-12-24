# Terraform Layout

This directory mirrors the infrastructure plan from the PRD. Modules encapsulate reusable building blocks (Kubernetes cluster, PostgreSQL, networking, monitoring). Environment folders (`environments/dev`, `environments/prod`) assemble those modules with environment-specific variables.

```
infra/terraform
├── global/          # backend configuration (state bucket, locking)
├── modules/
│   ├── networking/  # VPC, subnets, routes, IGW/NAT
│   ├── kubernetes/  # EKS cluster + managed node groups + IRSA
│   ├── database/    # RDS PostgreSQL primary + optional replica
│   └── monitoring/  # Prometheus/Grafana/Jaeger via Helm
└── environments/
    ├── dev/
    └── prod/
```

## Usage (example for dev)

```bash
cd infra/terraform/environments/dev
terraform init -backend-config=../backend-dev.hcl
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Each environment references the same modules but with different scaling, subnet counts, and database sizes. Add `*.tfvars` files with secrets excluded from version control.

### Required variables

Both stacks expect the following sensitive values:

```hcl
db_username            = "zenx_admin"
db_password            = "super-secure-password"
grafana_admin_password = "another-secure-password"
```

Store them in a local `terraform.tfvars`/`dev.tfvars` file or pass via `-var` flags (never commit secrets).

### Module overview

| Module      | Responsibilities                                                                                                   | Key outputs                                   |
|-------------|-------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| networking  | Dedicated VPC, public/private subnets, route tables, Internet/NAT gateways, shared tagging                         | `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `vpc_cidr_block` |
| kubernetes  | EKS control plane + managed node groups (IRSA enabled, multi-AZ), exposes certificate + endpoint for Helm installs | `cluster_name`, `cluster_endpoint`, `cluster_ca_certificate`, `node_security_group_id` |
| database    | RDS PostgreSQL instance w/ parameter + subnet groups, SG, optional replica                                         | `primary_endpoint`, `reader_endpoint`, `security_group_id` |
| monitoring  | Installs `kube-prometheus-stack` (Prometheus + Grafana) and Jaeger through Helm                                    | `grafana_namespace`, `prometheus_service_name`, `jaeger_service_name` |

### Observability

The monitoring module requires a Kubernetes token. Each environment fetches a token from the created EKS cluster via `aws_eks_cluster_auth` and hands it to the module so Helm can talk to the cluster. Grafana is published through a `LoadBalancer` Service—AWS will assign the DNS name once the chart is installed.

### Remote state

`infra/terraform/global/backend.tf` is configured for an S3 bucket named `zenx-terraform-state` with DynamoDB locking. Update those names to match your AWS account before running `terraform init -backend-config=../backend-<env>.hcl`.
