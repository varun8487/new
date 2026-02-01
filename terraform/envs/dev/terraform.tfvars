# Resource Configuration
location           = "eastus"
rg_name            = "MAHLE"
image_rg           = "MAHLE"
managed_image_name = "Ubuntu-Golden-POC-1769783997"

# VM Configuration
name_prefix    = "imgpoc"
vm_size        = "Standard_DS2_v2"
admin_username = "azureuser"

# Network Security - Allow SSH from anywhere for POC
allowed_ssh_ips = ["0.0.0.0/0"]

tags = {
  Project     = "ImagePOC"
  Owner       = "DevOps"
  Environment = "Dev"
  ManagedBy   = "Terraform"
}
