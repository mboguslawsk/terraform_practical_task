# ====== TERRAFORM =======

variable "project_name" {
  description = "Project name for GCP"
}

variable "region" {
  description = "Region name for GCP"
}

variable "vm_zone_main" {
  description = "Zone name for GCP project"
}


# ====== OTHERS =======

variable "prefix" {
  description = "Just random word regarding your project"
}

variable "count_vms" {
  description = "Number of VMs in the backend."
}