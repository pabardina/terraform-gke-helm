resource "google_sql_database_instance" "mysql" {
  name             = format("%s-sql-mysql-57", var.gke_cluster_name)
  database_version = "MYSQL_5_7"

  settings {
    tier              = "db-custom-4-8704"
    availability_type = "REGIONAL"

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.vpc-gke.self_link
    }

    user_labels = var.labels
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

//resource "random_password" "sql-password" {
//  length           = 40
//  special          = true
//  override_special = "_%@"
//  depends_on       = ["google_sql_database_instance.postgres"]
//}

resource "google_sql_database" "app" {
  name     = var.sql_database
  instance = google_sql_database_instance.mysql.name
}


resource "google_sql_user" "app_user" {
  instance = google_sql_database_instance.mysql.name
  name     = var.sql_username
  //  password = random_password.sql-password.result
  password = var.sql_password
  host     = "%"
}

