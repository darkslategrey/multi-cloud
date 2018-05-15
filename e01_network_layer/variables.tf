# Commons

variable "private_key_path" {
  default = "~/.ssh/google_compute_engine"
}

# GCP Vars

variable "gcp_project" {
  default = "courseur-1234"
}
variable "gcp_user" {
  default = "Courseur"
}

variable "region_gcp" {
  default = "europe-west1"
}

variable "az_gcp" {
  default = [
      "b",
      "c",
      "d"
    ]
}

variable "gcp_instance_type" {
  default = "f1-micro"
}

variable "gcp_image" {
  default = "centos-7-v20170426"
}

variable "bgp_gcp" {
  default = "65273"
}
