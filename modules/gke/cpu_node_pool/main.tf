variable "cluster" {}
variable "node_pool_count" {
  default = 4
}
variable "max_node_count" {
  default = 4
}
variable "disk_size_gb" {
  default = 15
}
variable "preemtible" {
  default = true
}

resource "google_container_node_pool" "g1-samll" {
  count      = "${var.node_pool_count == 0 ? 0 : 1}"
  name       = "g1-small"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemtible}"
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "g1-small"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "cpu-mem-1024" {
  count      = "${var.node_pool_count}"
  name       = "cpu-${pow(2, count.index)}-mem-${pow(2, count.index) * 1024}"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemtible}"
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "custom-${pow(2, count.index)}-${pow(2, count.index) * 1024}"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "cpu-mem-1536" {
  count      = "${var.node_pool_count}"
  name       = "cpu-${pow(2, count.index)}-mem-${pow(2, count.index) * 1536}"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemtible}"
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "custom-${pow(2, count.index)}-${pow(2, count.index) * 1536}"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "cpu-mem-2048" {
  count      = "${var.node_pool_count}"
  name       = "cpu-${pow(2, count.index)}-mem-${pow(2, count.index) * 2048}"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemtible}"
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "custom-${pow(2, count.index)}-${pow(2, count.index) * 2048}"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


resource "google_container_node_pool" "cpu-mem-4096" {
  count      = "${var.node_pool_count}"
  name       = "cpu-${pow(2, count.index)}-mem-${pow(2, count.index) * 4096}"
  cluster    = "${var.cluster}"
  node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemtible}"
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "custom-${pow(2, count.index)}-${pow(2, count.index) * 4096}"

    metadata = "${map("disable-legacy-endpoints", "true")}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
