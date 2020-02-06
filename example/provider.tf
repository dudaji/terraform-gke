variable "project" {
  default = "project-name"
}

provider "google" {
  credentials = "${file("../key.json")}"
  project     = "${var.project}"
  zone        = "asia-northeast-3"
}
