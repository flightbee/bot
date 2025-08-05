resource "google_compute_instance" "vm_instance" {
    name         = var.instance_name
    machine_type = var.machine_type
    zone         = var.zone

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-minimal-2404-noble-amd64-v20250710"
        }
    }

    network_interface {
        network = "default"
        access_config {}
    }

    metadata = {
        ssh-keys = "${var.ssh_user}:${var.public_key}"
    }
}