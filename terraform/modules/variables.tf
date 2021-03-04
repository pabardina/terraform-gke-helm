variable "project_id" {
  type        = string
  description = "The GCP project ID where the resources are created"
}

variable "region" {
  type        = string
  description = "The GCP region where the resources are created"
  default     = "northamerica-northeast1" # 3 AZ for this region
}

variable "gke_cluster_name" {
  type    = string
  default = "gke-cluster"
}

variable "gke_subnet_cid" {
  type    = string
  default = "10.0.0.0/24"
}

variable "gke_subnet_cluster_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "gke_subnet_services_cidr" {
  type    = string
  default = "10.2.0.0/20"
}

variable "sql_username" {
  type    = string
  default = "username"
}

variable "sql_database" {
  type    = string
  default = "password"
}

variable "k8s_namespace" {
  type    = string
  default = "default"
}

variable "k8s_ksa" {
  type    = string
  default = "app-ksa"
}

variable "project_services" {
  type = list(string)

  default = [
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "securetoken.googleapis.com",
  ]
  description = <<-EOF
  The GCP APIs that should be enabled in this project.
  EOF
}
