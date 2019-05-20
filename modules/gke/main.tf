variable "name" {}

resource "google_container_cluster" "ml_cluster" {
  name                     = "${var.name}"
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "1.12.7-gke.10"
  monitoring_service       = "none"
  logging_service          = "none"
  location                 = "us-central1-c"

  master_auth {
    username = ""
    password = ""
  }
}

module "cpu_pool" {
  source  = "./cpu_node_pool"
  cluster = "${google_container_cluster.ml_cluster.name}"
}

module "gpu_pool_k80" {
  source   = "./gpu_node_pool"
  cluster  = "${google_container_cluster.ml_cluster.name}"
  gpu_type = "nvidia-tesla-k80"
}
