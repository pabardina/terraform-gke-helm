resource "google_pubsub_topic" "pubsub" {
  name   = format("%s-pubsub", var.gke_cluster_name)
  labels = var.labels
}

resource "google_pubsub_subscription" "pubsub-sub" {
  name                 = format("%s-pubsub-sub", var.gke_cluster_name)
  topic                = google_pubsub_topic.pubsub.name
  ack_deadline_seconds = 10
  expiration_policy {
    ttl = "" # never expires
  }
  labels = var.labels
}