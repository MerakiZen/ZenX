terraform {
  required_version = ">= 1.7.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

variable "cluster_endpoint" {
  type        = string
}

variable "cluster_ca_certificate" {
  type        = string
  description = "Base64 encoded cluster CA"
}

variable "cluster_auth_token" {
  type        = string
  sensitive   = true
}

variable "observability_namespace" {
  type        = string
  default     = "observability"
}

variable "grafana_namespace" {
  type        = string
  default     = "observability"
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
}

variable "prometheus_retention" {
  type    = string
  default = "15d"
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.cluster_auth_token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = var.cluster_auth_token
  }
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.observability_namespace
  }
}

resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.observability.metadata[0].name

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = var.prometheus_retention
  }

  values = [
    yamlencode({
      grafana = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}

resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  namespace  = kubernetes_namespace.observability.metadata[0].name

  values = [
    yamlencode({
      provisionDataStore = {
        cassandra = false
      }
      storage = {
        type = "memory"
      }
      collector = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [helm_release.kube_prometheus]
}

output "grafana_namespace" {
  value       = kubernetes_namespace.observability.metadata[0].name
  description = "Namespace where Grafana is deployed"
}

output "grafana_admin_password" {
  value       = var.grafana_admin_password
  description = "Admin password (provided input)"
  sensitive   = true
}

output "prometheus_service_name" {
  value       = "${helm_release.kube_prometheus.name}-kube-p-prometheus"
  description = "Internal service name for Prometheus"
}

output "jaeger_service_name" {
  value       = helm_release.jaeger.name
  description = "Internal service name for Jaeger"
}
