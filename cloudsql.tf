resource "google_sql_database_instance" "my-cloud-sql" {
  name             = var.db_instance_name
  region           = var.region
  database_version = "MYSQL_5_7"
  tier             = var.db_tier
}

resource "google_sql_user" "my-cloud-sql-user" {
  name     = var.db_user_name
  instance = google_sql_database_instance.my-cloud-sql.name

  password = var.db_user_password
}

resource "google_sql_database" "my-cloud-sql-db" {
  name     = var.db_name
  instance = google_sql_database_instance.my-cloud-sql.name

  charset = "utf8"
  collation = "utf8_general_ci"
}

resource "google_service_networking_connection" "private-vpc-connection" {
  network    = google_container_cluster.my-cluster.network
  service    = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    "192.168.0.0/16"
  ]
}

resource "google_sql_database_instance_private_ip_configuration" "my-cloud-sql-private-ip" {
  name                     = "my-cloud-sql-private-ip"
  instance                 = google_sql_database_instance.my-cloud-sql.name
  authorized_networks      = ["${google_container_cluster.my-cluster.network.self_link}"]
  require_ssl              = true
  ipv4_enabled             = true
  private_network          = "${google_container_cluster.my-cluster.network.self_link}"
  private_service_access_config {
    enable_private_service_access = true
    service_name                 = "sqladmin.googleapis.com"
  }
}
