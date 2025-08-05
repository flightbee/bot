resource "null_resource" "update_inventory" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ../ansible/group_vars
      echo '[all]' > ../ansible/inventory
      echo '${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=~/.ssh/id_ed25519' >> ../ansible/inventory
      echo "---" > ../ansible/group_vars/all.yml
      echo "bot_dir: /opt/bot" >> ../ansible/group_vars/all.yml
      echo "ansible_python_interpreter: /usr/bin/python3" >> ../ansible/group_vars/all.yml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [google_compute_instance.vm_instance]
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 30
      cd ../ansible && ansible-playbook playbook.yml
    EOT
    interpreter = ["/usr/bin/python3", "-c"]
  }
  depends_on = [null_resource.update_inventory]
}