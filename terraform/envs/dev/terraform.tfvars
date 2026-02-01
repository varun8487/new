# Resource Configuration
location           = "eastus"
rg_name            = "rg-image-poc"
image_rg           = "rg-image-poc"
managed_image_name = "img-ubuntu-22"

# VM Configuration
name_prefix    = "imgpoc"
vm_size        = "Standard_D2s_v5"
admin_username = "azureuser"

# Network Security - Allow SSH from anywhere for POC
allowed_ssh_ips = ["0.0.0.0/0"]

tags = {
  Project     = "ImagePOC"
  Owner       = "DevOps"
  Environment = "Dev"
  ManagedBy   = "Terraform"
}
