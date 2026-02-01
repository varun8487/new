# =============================================================================
# Packer Template for Custom Ubuntu 22.04 LTS Image on Azure
# =============================================================================

packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.1"
    }
  }
}

# -----------------------------------------------------------------------------
# Source: Azure ARM Builder
# -----------------------------------------------------------------------------
source "azure-arm" "ubuntu" {
  # Authentication
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  # VM Configuration
  os_type  = "Linux"
  location = var.location
  vm_size  = var.vm_size

  # Base image from Azure Marketplace
  image_publisher = var.publisher
  image_offer     = var.offer
  image_sku       = var.sku

  # Output: Managed Image
  managed_image_resource_group_name = var.image_rg
  managed_image_name                = var.image_name

  # Temporary build resources
  build_resource_group_name = var.temp_rg

  # SSH Configuration
  communicator = "ssh"
  ssh_username = "azureuser"

  # Azure Tags
  azure_tags = {
    Project     = "ImagePOC"
    Owner       = "DevOps"
    Environment = "Dev"
    ManagedBy   = "Packer"
    BaseImage   = "Ubuntu-22.04-LTS"
  }
}

# -----------------------------------------------------------------------------
# Build Definition
# -----------------------------------------------------------------------------
build {
  name    = "ubuntu-22-image"
  sources = ["source.azure-arm.ubuntu"]

  # Baseline provisioning - install common packages
  provisioner "shell" {
    script = "scripts/base.sh"
  }

  # Optional: RDP-ready image with XFCE desktop
  # Uncomment the following block if you want RDP support baked into the image
  # provisioner "shell" {
  #   script = "scripts/xrdp.sh"
  # }

  # Generalize the VM for image capture
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
