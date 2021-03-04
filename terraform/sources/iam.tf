resource "google_service_account" "sa-gke" {
  account_id   = format("%s-sa", var.gke_cluster_name)
  display_name = "GKE Service Account"
}

resource "google_service_account" "sa-k8s-sql" {
  account_id   = format("%s-sa-k8s-cloudsql", var.gke_cluster_name)
  display_name = "GKE Service Account used for KSA sql"
}

resource "google_service_account" "sa-k8s-gcs" {
  account_id   = format("%s-sa-k8s-gcs", var.gke_cluster_name)
  display_name = "GKE Service Account used for KSA GCS"
}

data "google_iam_policy" "sa-k8s-cloudsql" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project_id, var.k8s_namespace, var.k8s_ksa_cloudsql)
    ]
  }
}

data "google_iam_policy" "sa-k8s-gcs" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project_id, var.k8s_namespace, var.k8s_ksa_gcs)
    ]
  }
}

resource "google_service_account_iam_policy" "sa-k8s-sql" {
  service_account_id = google_service_account.sa-k8s-sql.name
  policy_data        = data.google_iam_policy.sa-k8s-cloudsql.policy_data
}

resource "google_service_account_iam_policy" "sa-k8s-gcs" {
  service_account_id = google_service_account.sa-k8s-gcs.name
  policy_data        = data.google_iam_policy.sa-k8s-gcs.policy_data
}

resource "google_project_iam_binding" "sa-k8s-cloudsql" {
  role = "roles/cloudsql.client"

  members = [
    format("serviceAccount:%s", google_service_account.sa-k8s-sql.email)
  ]
}

resource "google_project_iam_binding" "sa-k8s-gcs" {
  role = "roles/storage.objectAdmin"

  members = [
    format("serviceAccount:%s", google_service_account.sa-k8s-gcs.email)
  ]
}

resource "google_project_iam_binding" "sa-k8s-pubsub" {
  role = "roles/pubsub.subscriber"

  members = [
    format("serviceAccount:%s", google_service_account.sa-k8s-gcs.email)
  ]
}

resource "google_project_service" "service" {
  count   = length(var.project_services)
  service = element(var.project_services, count.index)

  disable_on_destroy = false
}

