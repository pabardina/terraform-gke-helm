variable "project_id" {
  type        = string
  description = "The GCP project ID where the resources are created"
}

variable "region" {
  type        = string
  description = "The GCP region where the resources are created"
  default     = "northamerica-northeast1" # 3 AZ for this region
}

variable "labels" {
  type = map(any)
  default = {
    env     = "dev"
    project = "fake-project"
    owner   = "terraform"
  }
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

variable "gke_node_basic_flavor" {
  type    = string
  default = "e2-standard-4"
}

variable "gke_node_gpu_flavor" {
  type    = string
  default = "e2-small"
}

variable "sql_username" {
  type    = string
  default = "username"
}

variable "sql_password" {
  type    = string
  default = "supersecret"
}

variable "sql_database" {
  type    = string
  default = "app"
}

variable "k8s_namespaces" {
  type = list(string)
  default = [
    "app",
    "workload"
  ]
}

variable "k8s_namespace" {
  type    = string
  default = "app"
}

variable "k8s_ksa_cloudsql" {
  type    = string
  default = "ksa-app-cloudsql"
}

variable "k8s_ksa_gcs" {
  type    = string
  default = "ksa-app-gcs"
}

variable "project_services" {
  type = list(string)

  default = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securetoken.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
  ]
}
