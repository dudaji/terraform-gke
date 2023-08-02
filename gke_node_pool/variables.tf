variable "machine_type" {
  default = "n1"
}
variable "cluster" {}
variable "location" {}
variable "node_locations" {
  type    = list(string)
  default = null
}
variable "image_type" {
  default = "cos_containerd"
}
variable "gpu_type" {
  default = ""
}
variable "preemptible" {
  default = true
}
variable "disk_size_gb" {
  default = 15
}
variable "min_node_count" {
  default = 0
}
variable "max_node_count" {
  default = 4
}
variable "node_count" {
  default = 0
}
variable "node_pool_count" {
  default = 1
}
variable "cpu_start_exponent" {
  default = 0
}
variable "memory_coefficient" {
  default = 1024
}
variable "memory_start_exponent" {
  default = 0
}
variable "auto_upgrade" {
  default = false
}
