provider "google" {
  region  = var.region
  project = var.project_id
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.gke-cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.gke-cluster.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}
