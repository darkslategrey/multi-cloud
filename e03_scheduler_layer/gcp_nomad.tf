resource "google_compute_instance" "nomad_servers" {
  count        = 3
  name         = "server-gcp-nomad-servers-${count.index + 1}"
  machine_type = "${var.gcp_server_instance_type}"
  zone         = "${var.gcp_region}-${element(var.az_gcp, count.index)}"

  boot_disk {
    initialize_params {
      image = "${var.gcp_image}"
    }
  }

  # attached_disk {
  #   source = "${element(google_compute_disk.datanode-disks.*.self_link, 0)}"
  # }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  tags = ["nomad-servers", "consul-clients"]

  network_interface {
    subnetwork = "${data.terraform_remote_state.network.gcp_priv_subnet}"
  }

  service_account {
    scopes = [
        "https://www.googleapis.com/auth/compute.readonly"
      ]
  }

  metadata_startup_script = "${element(data.template_file.gcp_bootstrap_nomad_server.*.rendered, count.index)}"
}

data "template_file" "gcp_bootstrap_nomad_server" {
  count = 3
  template = "${file("bootstrap_nomad.tpl")}"

  vars {
    zone = "$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H \"Metadata-Flavor: Google\" | cut -d\"/\" -f4)"
    region = "$(echo $${ZONE} | cut -d\"-\" -f1)"
    idx = ""
    datacenter = "$(echo $${ZONE} | cut -d\"-\" -f1)-$(echo $${ZONE} | cut -d\"-\" -f2)"
    output_ip = "$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H \"Metadata-Flavor: Google\")"
    nomad_version = "0.8.3"
    consul_version = "1.0.7"
    node_type = "server"
    join = "\"retry_join\": [\"provider=gce tag_value=consul-servers\"]"
    dns1 = "${data.terraform_remote_state.consul.gcp_consul_ips.0}"
    dns2 = "${data.terraform_remote_state.consul.gcp_consul_ips.1}"
    dns3 = "${data.terraform_remote_state.consul.gcp_consul_ips.2}"
    persistent_disk = ""
    cloud = "gcp"
    node_class = "server"
    node_name = "server-gcp-nomad-servers-${count.index + 1}"
  }
}

resource "google_compute_instance" "nomad_clients" {
  count        = 3
  name         = "server-gcp-nomad-clients-${count.index + 1}"
  machine_type = "${var.gcp_client_instance_type}"
  zone         = "${var.gcp_region}-${element(var.az_gcp, count.index)}"

  boot_disk {
    initialize_params {
      image = "${var.gcp_image}"
    }
  }
  # TODO: remove attached disk
  # attached_disk {
  #   source = "${element(google_compute_disk.datanode-disks.*.self_link, count.index)}"
  # }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  tags = ["nomad-clients", "consul-clients"]

  network_interface {
    subnetwork = "${data.terraform_remote_state.network.gcp_priv_subnet}"
  }

  service_account {
    scopes = [
        "https://www.googleapis.com/auth/compute.readonly"
      ]
  }

  metadata_startup_script = "${element(data.template_file.gcp_bootstrap_nomad_client.*.rendered, count.index)}"

  depends_on = ["google_compute_instance.nomad_servers"]
}

data "template_file" "gcp_bootstrap_nomad_client" {
  count = 3
  template = "${file("bootstrap_nomad.tpl")}"

  vars {
    idx = "${count.index}"
    zone = "$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H \"Metadata-Flavor: Google\" | cut -d\"/\" -f4)"
    region = "$(echo $${ZONE} | cut -d\"-\" -f1)"
    datacenter = "$(echo $${ZONE} | cut -d\"-\" -f1)-$(echo $${ZONE} | cut -d\"-\" -f2)"
    output_ip = "$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H \"Metadata-Flavor: Google\")"
    nomad_version = "0.8.3"
    consul_version = "1.0.7"
    node_type = "client"
    dns1 = "${data.terraform_remote_state.consul.gcp_consul_ips.0}"
    dns2 = "${data.terraform_remote_state.consul.gcp_consul_ips.1}"
    dns3 = "${data.terraform_remote_state.consul.gcp_consul_ips.2}"
    join = "\"retry_join\": [\"provider=gce tag_value=consul-servers\"]"
    # persistent_disk = "/dev/sdb"
    persistent_disk = ""
    cloud = "gcp"
    node_class = "app"
    node_name = "server-gcp-nomad-clients-${count.index + 1}"
  }
}

resource "google_compute_disk" "datanode-disks" {
  count = 0
  type  = "pd-standard"
  name  = "datanode-disks-${count.index + 1}"
  zone  = "${var.gcp_region}-${element(var.az_gcp, count.index)}"
  size  = 50
}
