resource "null_resource" "update_inventory" {
  provisioner "local-exec" {
    command = "echo '${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=~/.ssh/id_ed25519' > ../ansible/inventory"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [google_compute_instance.vm_instance]
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "sleep 30 && cd ../ansible && ansible-playbook playbook.yml"
  }
  depends_on = [null_resource.update_inventory]
}
