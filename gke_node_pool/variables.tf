variable "machine_type" {
  default = "n1"
}
variable "cluster" {}
variable "location" {}
variable "gpu_type" {
  default = ""
}
variable "preemtible" {
  default = true
}
variable "disk_size_gb" {
  default = 15
}
variable "max_node_count" {
  default = 4
}
variable node_count {
  default = 0
}
variable "node_pool_count" {
  default = 1
}

variable cpu_start_exponent {
  default = 0
}
variable "memory_coefficient" {
  default = 1024
}
variable "memory_start_exponent" {
  default = 0
}
