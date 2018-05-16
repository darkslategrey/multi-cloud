resource "google_compute_disk" "persistent-disks" {
  count = 2
  type  = "pd-standard"
  name  = "persistent-disks-${count.index + 1}"
  zone  = "${var.gcp_region}-b"
  size = 20
}
