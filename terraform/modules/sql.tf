resource "google_sql_database_instance" "postgres" {
  name             = format("%s-postgres", var.gke_cluster_name)
  database_version = "POSTGRES_11"

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.vpc-gke.self_link
    }
  }

//  lifecycle {
//    prevent_destroy = true
//  }
  depends_on = [
    "google_service_networking_connection.private_vpc_connection"
  ]
}

resource "random_password" "sql-password" {
  length           = 40
  special          = true
  override_special = "_%@"
  depends_on       = ["google_sql_database_instance.postgres"]
}

resource "google_sql_database" "app" {
  name     = var.sql_database
  instance = google_sql_database_instance.postgres.name
}


resource "google_sql_user" "app_user" {
  instance = google_sql_database_instance.postgres.name
  name     = var.sql_username
  password = random_password.sql-password.result
}

