terraform {
  # backend "gcs" {
  #   bucket = "bm-084243-tfstate-bucket"
  #   prefix  = "terraform/state"
  # }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.1.1"
    }
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
  zone    = var.vm_zone_main
}

resource "google_storage_bucket" "tfstate_backend" {
  name                        = "${local.name_prefix}-tfstate-bucket"
  project                     = var.project_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}


locals {
  name_prefix = "${var.prefix}-${substr(md5(var.prefix), 0, 6)}"
}


module "network" {
  source      = "./modules/network"
  prefix_name = local.name_prefix
  region      = var.region
}

module "compute" {
  source      = "./modules/compute"
  project     = var.project_name
  prefix_name = local.name_prefix
  zone        = var.vm_zone_main
  net         = module.network.net
  subnet      = module.network.subnet
  count_vms   = var.count_vms
  external_ip = module.network.external-ip
}

output "load_balancer_ip" {
  description = "External IP of the load balancer"
  value       = module.network.external-ip-value
}

output "bucket_name" {
  value = google_storage_bucket.tfstate_backend.name
}