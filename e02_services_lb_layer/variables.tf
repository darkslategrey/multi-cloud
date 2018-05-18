# Commons

variable "domain" {
  default = "courseur.com"
}

variable "test" {
  default = false
}

variable "gcp_project" {
  default = "courseur-1234"
}

variable "gcp_user" {
  default = "courseur"
}

variable "gcp_region" {
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
