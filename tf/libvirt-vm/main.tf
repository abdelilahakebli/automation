terraform {
  required_providers {
    libvirt = {
      source : "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "vm_disk" {
  name   = "${var.vm_name}_disk.qcow2"
  pool   = "tf"
  source = var.image_source
  # size   = var.vm_disk_size # Size in gigabytes
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${var.cloud_init_config}")
  vars = {
    hostname       = var.vm_name
    username       = var.ssh_username
    ssh-public-key = file("${var.ssh_key_public}")
  }
}


data "template_file" "network_config" {
  template = file("${var.network_init_config}")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.vm_name}-commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = "tf"
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
    hostname       = var.vm_name
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      host        = libvirt_domain.vm.network_interface[0].addresses[0]
      private_key = file(var.ssh_key_private)
      timeout     = "2m"
    }
  }
}
