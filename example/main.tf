variable "project" {}

provider "google" {
  # credentials = file("../key.json")
  project = var.project
}

locals {
  location = "us-central1-a"
}
resource "google_container_cluster" "ml_cluster" {
  name                     = "dudaji-terraform-gke-example-cluster"
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "latest"
  monitoring_service       = "none"
  logging_service          = "none"
  location                 = local.location

  master_auth {
    username = ""
    password = ""
  }
}

module "cpu-pool" {
  source       = "../gke_node_pool"
  cluster      = "${google_container_cluster.ml_cluster.name}"
  location     = local.location
  node_count   = 1
  machine_type = "g1-small"
}

module "gpu-pool" {
  source             = "../gke_node_pool"
  cluster            = "${google_container_cluster.ml_cluster.name}"
  location           = local.location
  node_pool_count    = 2
  machine_type       = "n1"
  cpu_start_exponent = 2
  memory_coefficient = 1024 * 16
  gpu_type           = "nvidia-tesla-t4"
}

