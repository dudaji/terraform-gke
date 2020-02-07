resource "google_container_cluster" "ml_cluster" {
  name                     = "dudaji-terraform-gke-example-cluster"
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "latest"
  monitoring_service       = "none"
  logging_service          = "none"

  master_auth {
    username = ""
    password = ""
  }
}

resource "google_container_node_pool" "g1-small" {
  name       = "g1-small"
  cluster    = "${google_container_cluster.ml_cluster.name}"
  node_count = 1

  autoscaling {
    min_node_count = 0
    max_node_count = 8
  }

  node_config {
    preemptible  = true
    disk_size_gb = 10
    machine_type = "g1-small"
    metadata     = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

module "gpu_pool_k80" {
  source   = "../modules/gke/gpu_node_pool"
  cluster  = "${google_container_cluster.ml_cluster.name}"
  gpu_type = "nvidia-tesla-k80"
}
