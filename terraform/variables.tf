# =============================================================================
# Terraform Variables
# =============================================================================
# Authentication: Set these environment variables before running:
#   export ARM_SUBSCRIPTION_ID="..."
#   export ARM_TENANT_ID="..."
#   export ARM_CLIENT_ID="..."
#   export ARM_CLIENT_SECRET="..."
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------
variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for resources"
}

variable "rg_name" {
  type        = string
  default     = "rg-image-poc"
  description = "Name of the resource group for VM resources"
}

variable "image_rg" {
  type        = string
  default     = "rg-image-poc"
  description = "Resource group containing the Packer-built image"
}

variable "managed_image_name" {
  type        = string
  default     = "img-ubuntu-22"
  description = "Name of the managed image built by Packer"
}

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------
variable "name_prefix" {
  type        = string
  default     = "imgpoc"
  description = "Prefix for all resource names"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v5"
  description = "Size of the virtual machine"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Admin username for the VM"
}

# -----------------------------------------------------------------------------
# Network Security
# -----------------------------------------------------------------------------
variable "allowed_ssh_ips" {
  type        = list(string)
  description = "List of IP addresses allowed to SSH (CIDR notation)"
  default     = []
}

variable "allowed_rdp_ips" {
  type        = list(string)
  description = "List of IP addresses allowed to RDP (CIDR notation)"
  default     = []
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Project     = "ImagePOC"
    Owner       = "DevOps"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
