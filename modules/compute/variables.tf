variable "project" {
    description = "Project in GCP"
}

variable "prefix_name" {
  description = "Just random word regarding your project for service names"
}

variable "zone" {
    description = "Zone for Compute Instance in GCP"
}

variable "net" {
    description = "Network in GCP"
}

variable "subnet" {
    description = "Subnetwork in GCP"
}

variable "count_vms" {
    description = "Number of VMs in the backend."
}

variable "external_ip" {
    description = "External IP for LB."
}