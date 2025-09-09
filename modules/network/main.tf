# VPC
resource "google_compute_network" "default" {
  name                    = "${var.prefix_name}-xlb-network"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "${var.prefix_name}-xlb-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name = "${var.prefix_name}-xlb-static-ip"
}

# outputs
output "external-ip" {
  value = google_compute_global_address.default.self_link
}

output "external-ip-value" {
  value = google_compute_global_address.default.address
}

output "net" {
  value = google_compute_network.default.id
}

output "subnet" {
  value = google_compute_subnetwork.default.id
}
