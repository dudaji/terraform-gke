variable "cluster" {}

resource "google_container_node_pool" "cpu" {
  count      = 4
  name       = "cpu-${pow(2, count.index)}"
  cluster    = "${var.cluster}"
  node_count = "${(count.index == 0 ? 1 : 0)}"

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }

  node_config {
    preemptible  = true
    disk_size_gb = 20
    machine_type = "custom-${pow(2, count.index)}-${pow(2, count.index) * 2048}"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
