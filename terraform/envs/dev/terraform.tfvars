# Azure Authentication (from Service Principal)
subscription_id = "<YOUR_SUBSCRIPTION_ID>"
tenant_id       = "<YOUR_TENANT_ID>"
client_id       = "<YOUR_CLIENT_ID>"
client_secret   = "<YOUR_CLIENT_SECRET>"

# Resource Configuration
location           = "eastus"
rg_name            = "rg-image-poc"
image_rg           = "rg-image-poc"
managed_image_name = "img-ubuntu-22"

# VM Configuration
name_prefix    = "imgpoc"
vm_size        = "Standard_D2s_v5"
admin_username = "azureuser"

# Network Security - Replace with your public IP
allowed_ssh_ips = ["<YOUR_PUBLIC_IP>/32"]

tags = {
  Project     = "ImagePOC"
  Owner       = "DevOps"
  Environment = "Dev"
  ManagedBy   = "Terraform"
}
