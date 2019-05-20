variable "cluster" {}
variable "gpu_type" {}

resource "google_container_node_pool" "gpu" {
  count      = 4
  name       = "${var.gpu_type}-${pow(2, count.index)}"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = 8
  }

  node_config {
    preemptible  = true
    disk_size_gb = 30
    machine_type = "custom-${pow(2, count.index) * 2}-${pow(2, count.index) * 10240}"
    metadata     = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    guest_accelerator {
      type  = "${var.gpu_type}"
      count = "${pow(2, count.index)}"
    }
  }
}
