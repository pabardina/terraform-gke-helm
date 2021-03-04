resource "google_compute_network" "vpc-gke" {
  name                    = format("%s-net", var.gke_cluster_name)
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

# necessaire pour mysql privé
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = format("%s-priv-ip", var.gke_cluster_name)
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc-gke.self_link
}

# necessaire pour mysql privé
resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.vpc-gke.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_address" "nat" {
  name = format("%s-nat-ip", var.gke_cluster_name)

}

resource "google_compute_router" "router" {
  name    = format("%s-cloud-router", var.gke_cluster_name)
  network = google_compute_network.vpc-gke.self_link
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name   = format("%s-cloud-nat", var.gke_cluster_name)
  router = google_compute_router.router.name

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet_gke.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      google_compute_subnetwork.subnet_gke.secondary_ip_range.0.range_name,
      google_compute_subnetwork.subnet_gke.secondary_ip_range.1.range_name,
    ]
  }
}