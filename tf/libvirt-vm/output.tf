output "vcpu" {
  value = var.vm_vcpu
}
output "ram" {
  value = "${var.vm_memory} MB"
}

output "disk" {
  value = "${libvirt_volume.vm_disk.size / 1024 / 1024 / 1024} GB"
}
output "hostname" {
  value = var.vm_name
}
output "user" {
  value = var.ssh_username
}

output "public_ip" {
  value = libvirt_domain.vm.network_interface[0].addresses[0]
}
