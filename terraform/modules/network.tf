resource "google_compute_network" "vpc-gke" {
  name                    = format("%s-network", var.gke_cluster_name)
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet_gke" {
  name                     = format("%s-subnet", var.gke_cluster_name)
  network                  = google_compute_network.vpc-gke.id
  ip_cidr_range            = var.gke_subnet_cid
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = format("%s-pod-range", var.gke_cluster_name)
    ip_cidr_range = var.gke_subnet_cluster_cidr
  }
  secondary_ip_range {
    range_name    = format("%s-svc-range", var.gke_cluster_name)
    ip_cidr_range = var.gke_subnet_services_cidr
  }
}

resource "google_compute_global_address" "private_ip_address" {
  provider = "google-beta"

  name          = format("%s-priv-ip", var.gke_cluster_name)
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc-gke.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = "google-beta"

  network                 = google_compute_network.vpc-gke.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
