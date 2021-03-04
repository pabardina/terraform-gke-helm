resource "google_storage_bucket" "bucket-gcs" {
  name          = format("%s-subnet-test-quebec", var.gke_cluster_name)
  force_destroy = true

  uniform_bucket_level_access = true

  labels = var.labels

}