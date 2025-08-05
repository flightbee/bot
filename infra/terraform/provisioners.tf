resource "null_resource" "update_inventory" {
  provisioner "local-exec" {
    command = <<EOT
      echo '[all]
      ${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=~/.ssh/id_ed25519' > ../ansible/inventory.ini
      
      # Создаём переменные для Ansible
      echo "bot_dir: /home/${var.ssh_user}/bot" > ../ansible/group_vars/all.yml
      echo "terraform_vm_ip: ${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}" >> ../ansible/group_vars/all.yml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [google_compute_instance.vm_instance]
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "sleep 30 && cd ../ansible && ansible-playbook -i inventory.ini deploy_bot.yml"
  }
  depends_on = [null_resource.update_inventory]
}