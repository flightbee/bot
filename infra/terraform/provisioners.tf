resource "null_resource" "update_inventory" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ../ansible/group_vars
      echo '[all]' > ../ansible/inventory.ini
      echo '${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.public_key}' >> ../ansible/inventory.ini
      echo "---" > ../ansible/group_vars/all.yml
      echo "bot_dir: /home/${var.ssh_user}/bot" >> ../ansible/group_vars/all.yml
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
      cd ../ansible && ansible-playbook -i inventory.ini deploy_bot.yml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [null_resource.update_inventory]
}