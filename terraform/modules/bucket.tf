resource "google_storage_bucket" "static-site" {
  name          = format("%s-subnet-test-quebec", var.gke_cluster_name)
  force_destroy = true

  uniform_bucket_level_access = true

}