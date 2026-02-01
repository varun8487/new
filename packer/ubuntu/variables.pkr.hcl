# =============================================================================
# Packer Variables for Azure Ubuntu Image
# =============================================================================
# Authentication: Set these environment variables before running:
#   export ARM_SUBSCRIPTION_ID="..."
#   export ARM_TENANT_ID="..."
#   export ARM_CLIENT_ID="..."
#   export ARM_CLIENT_SECRET="..."
# =============================================================================

# -----------------------------------------------------------------------------
# Azure Authentication (reads from ARM_* environment variables)
# -----------------------------------------------------------------------------
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  default     = env("ARM_SUBSCRIPTION_ID")
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  default     = env("ARM_TENANT_ID")
}

variable "client_id" {
  type        = string
  description = "Azure Service Principal Client ID"
  default     = env("ARM_CLIENT_ID")
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principal Client Secret"
  sensitive   = true
  default     = env("ARM_CLIENT_SECRET")
}

# -----------------------------------------------------------------------------
# Azure Resources
# -----------------------------------------------------------------------------
variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for resources"
}

variable "image_rg" {
  type        = string
  default     = "rg-image-poc"
  description = "Resource group where the managed image will be stored"
}

variable "image_name" {
  type        = string
  default     = "img-ubuntu-22"
  description = "Name of the managed image to create"
}

variable "temp_rg" {
  type        = string
  default     = "rg-packer-temp"
  description = "Resource group for temporary build resources"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v5"
  description = "VM size for the build VM"
}

# -----------------------------------------------------------------------------
# Base Image (Ubuntu 22.04 LTS from Canonical)
# -----------------------------------------------------------------------------
variable "publisher" {
  type        = string
  default     = "Canonical"
  description = "Image publisher"
}

variable "offer" {
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
  description = "Image offer"
}

variable "sku" {
  type        = string
  default     = "22_04-lts-gen2"
  description = "Image SKU"
}
