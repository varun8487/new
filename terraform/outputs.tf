# =============================================================================
# Terraform Outputs
# =============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.rg.name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "admin_username" {
  description = "Admin username for SSH access"
  value       = var.admin_username
}

output "admin_password" {
  description = "Admin password for SSH access"
  value       = random_password.admin.result
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}

output "image_used" {
  description = "ID of the Packer-built image used"
  value       = data.azurerm_image.packer_img.id
}
