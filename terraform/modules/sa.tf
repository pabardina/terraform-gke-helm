resource "google_service_account" "sa-gke" {
  account_id   = format("%s-sa", var.gke_cluster_name)
  display_name = "GKE Service Account"
}

resource "google_service_account" "sa-k8s" {
  account_id = format("%s-sa-k8s", var.gke_cluster_name)
}

data "google_iam_policy" "sa-k8s" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project_id, var.k8s_namespace, var.k8s_ksa)
    ]
  }
}

resource "google_service_account_iam_policy" "sa-k8s" {
  service_account_id = google_service_account.sa-k8s.name
  policy_data        = data.google_iam_policy.sa-k8s.policy_data
}

resource "google_project_iam_binding" "sa-k8s-cloudsql" {
  role = "roles/cloudsql.client"

  members = [
    format("serviceAccount:%s", google_service_account.sa-k8s.email)
  ]
}

//resource "google_service_account_iam_binding" "admin-account-iam" {
//  service_account_id = google_service_account.sa-kubernetes.name
//  role               = "roles/iam.workloadIdentityUser"
//
//  members = [
//    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa}]"
//  ]
//}

// Enable required services on the project
resource "google_project_service" "service" {
  count   = length(var.project_services)
  service = element(var.project_services, count.index)

  // Do not disable the service on destroy. On destroy, we are going to
  // destroy the project, but we need the APIs available to destroy the
  // underlying resources.
  disable_on_destroy = false
}