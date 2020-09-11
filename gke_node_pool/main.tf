resource "google_container_node_pool" "custom-node-pool" {
  name       = substr(local.name[count.index], 0, 40)
  count      = local.node_pool_count
  cluster    = var.cluster
  location   = var.location
  node_count = var.node_count

  autoscaling {
    min_node_count = 0
    max_node_count = var.max_node_count
  }

  node_config {
    image_type   = var.image_type
    preemptible  = var.preemtible
    disk_size_gb = var.disk_size_gb
    machine_type = local.machine_type[count.index]

    metadata = map("disable-legacy-endpoints", "true")

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    guest_accelerator {
      type  = var.gpu_type
      count = local.gpu_count[count.index]
    }
  }
}
