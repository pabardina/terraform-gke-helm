data "google_container_engine_versions" "version" {
  location       = var.region
  version_prefix = "latest"
}

resource "google_container_cluster" "gke-cluster" {
  provider = google-beta
  location = var.region

  name            = var.gke_cluster_name
  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.vpc-gke.self_link
  subnetwork      = google_compute_subnetwork.subnet_gke.self_link

  min_master_version = data.google_container_engine_versions.version.latest_master_version
  node_version       = data.google_container_engine_versions.version.latest_node_version

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  remove_default_node_pool = true # la recommandation est d'avoir des nodes pool custom
  initial_node_count       = 1

  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.16/28"
    enable_private_endpoint = false
    enable_private_nodes    = true
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet_gke.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.subnet_gke.secondary_ip_range.1.range_name
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    istio_config {
      disabled = false
    }
  }

  network_policy {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = format("%s.svc.id.goog", var.project_id)
  }

  resource_labels = var.labels

}

resource "google_container_node_pool" "np-gke-basic" {
  location = google_container_cluster.gke-cluster.location
  name     = format("%s-basic", var.gke_cluster_name)
  cluster  = google_container_cluster.gke-cluster.name

  initial_node_count = 1 # per AZ

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  node_config {
    service_account = google_service_account.sa-gke.email
    machine_type    = var.gke_node_basic_flavor
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env  = "test"
      type = "basic"
    }
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }

  depends_on = [
    google_container_cluster.gke-cluster,
  ]
}

resource "google_container_node_pool" "np-gke-gpu" {
  location = google_container_cluster.gke-cluster.location
  name     = format("%s-gpu", var.gke_cluster_name)
  cluster  = google_container_cluster.gke-cluster.name

  initial_node_count = 1 # per AZ

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  node_config {
    service_account = google_service_account.sa-gke.email
    machine_type    = var.gke_node_gpu_flavor # imagine we have GPU machine
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env  = "test"
      type = "gpu"
    }

    # used to avoid basic pod to be scheduled here
    taint = [
      {
        effect = "NO_SCHEDULE"
        key    = "type"
        value  = "gpu"
      }
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }

  depends_on = [
    google_container_cluster.gke-cluster,
  ]
}
