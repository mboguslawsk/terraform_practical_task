# =========================== Temporary VM & Custom Image ===========================

resource "google_compute_instance" "vm_for_image" {
  name         = "${var.prefix_name}-img-builder"
  machine_type = "e2-small"
  zone         = var.zone
  tags         = ["allow-health-check"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.net
    subnetwork = var.subnet
    access_config {}
  }

  metadata_startup_script = file("modules/compute/startupscript.sh")

  lifecycle {
    create_before_destroy = true
  }

  # Keep the VM stopped after provisioning
  desired_status = "TERMINATED"
}

resource "google_compute_image" "img_from_boot_dsk" {
  depends_on  = [google_compute_instance.vm_for_image]
  name        = "${var.prefix_name}-justimg"
  project     = var.project
  source_disk = google_compute_instance.vm_for_image.boot_disk[0].source
}

# =========================== External Application Load Balancer with MIG backend ===========================

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.prefix_name}-xlb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = var.external_ip
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.prefix_name}-xlb-target-http-proxy"
  url_map = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "${var.prefix_name}-xlb-url-map"
  default_service = google_compute_backend_service.default.id
}

# backend service
resource "google_compute_backend_service" "default" {
  name                  = "${var.prefix_name}-xlb-backend-service"
  protocol              = "HTTP"
  port_name             = "http" # must match MIG named_port
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = true
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "${var.prefix_name}-xlb-mig-template"
  machine_type = "e2-small"
  tags         = ["allow-health-check", "web-vms"]

  network_interface {
    network    = var.net
    subnetwork = var.subnet
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = google_compute_image.img_from_boot_dsk.self_link
  }

  metadata_startup_script = file("modules/compute/startupscript.sh")

  lifecycle {
    create_before_destroy = true
  }
}


# health check
resource "google_compute_health_check" "default" {
  name = "${var.prefix_name}-xlb-hc"

  http_health_check {
    # port_specification = "USE_SERVING_PORT"
    port = "80"
  }
}

# MIG
resource "google_compute_instance_group_manager" "default" {
  name              = "${var.prefix_name}-xlb-mig1"
  zone              = var.zone
  base_instance_name = "${var.prefix_name}-vm"
  target_size       = var.count_vms

  named_port {
    name = "http"
    port = 80
  }

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
}

# Firewall rules
resource "google_compute_firewall" "default" {
  name          = "${var.prefix_name}-xlb-fw-allow-hc"
  direction     = "INGRESS"
  network       = var.net
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  target_tags = ["allow-health-check"]
}

resource "google_compute_firewall" "allow_users_limit" {
  name          = "${var.prefix_name}-xlb-fw-allow-users-lim"
  direction     = "INGRESS"
  network       = var.net
  
  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = ["37.0.0.0/8"]
  target_tags = ["web-vms"]
}
