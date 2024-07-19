provider "local" {}

resource "null_resource" "ansible_provision" {
  provisioner "local-exec" {
    command = <<EOT
      inv_file="${var.vm_path}/inventory.ini"
      echo "[vm]" > $inv_file
      echo "${libvirt_domain.vm.network_interface[0].addresses[0]}" >> $inv_file
      echo "[vm:vars]" >> $inv_file
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'" >> $inv_file
    EOT
  }

  depends_on = [libvirt_domain.vm]
}
