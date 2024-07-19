variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "terraform-libvirt-vm"
}

variable "vm_memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default     = 2048
}

variable "vm_vcpu" {
  description = "The number of virtual CPUs"
  type        = number
  default     = 2
}


variable "image_source" {
  description = "The source URL or path to the base image"
  type        = string
}

variable "image_format" {
  description = "The format of the base image (e.g., qcow2)"
  type        = string
  default     = "qcow2"
}

variable "vm_disk_size" {
  description = "The size of the VM disk in GB"
  type        = number
  default     = 10
}


variable "ssh_username" {
  description = "SSH Username"
  default     = "cloud-user"
}
variable "ssh_key_public" {
  description = "SSH Public Key"
}
variable "ssh_key_private" {
  description = "SSH private key"
}
variable "network_init_config" {
  description = "Network init file."
}

variable "cloud_init_config" {
  description = "Cloud init file."
}


variable "playbooks_path" {
  description = "Playbooks PATH"
}

variable "vm_path" {
  description = "VM Dir Path"
}