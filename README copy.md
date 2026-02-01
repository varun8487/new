# Azure Image POC - Custom Ubuntu Image with Packer & Terraform

This project demonstrates how to:
1. Build a custom Ubuntu 22.04 LTS image using **Packer**
2. Deploy a VM from that custom image using **Terraform**

## Prerequisites

Before you begin, ensure you have:

- [ ] Azure subscription with Contributor access
- [ ] Azure CLI installed and logged in (`az login`)
- [ ] Packer installed (v1.9+) - https://developer.hashicorp.com/packer/install
- [ ] Terraform installed (v1.6+) - https://developer.hashicorp.com/terraform/install
- [ ] A Service Principal with Contributor role

## Directory Structure

```
azure-image-poc/
├── packer/
│   └── ubuntu/
│       ├── variables.pkr.hcl    # Packer variable definitions
│       ├── ubuntu.pkr.hcl       # Packer template
│       └── scripts/
│           ├── base.sh          # Base provisioning script
│           └── xrdp.sh          # Optional: RDP/XFCE setup
├── terraform/
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   └── envs/
│       └── dev/
│           └── terraform.tfvars # Environment-specific values
├── .gitignore
└── README.md
```

## Step 1: Azure Setup (One-time)

### 1.1 Set Environment Variables
```bash
export SUBID="<your-subscription-id>"
export LOCATION="eastus"
export IMAGE_RG="rg-image-poc"
export TEMP_RG="rg-packer-temp"
```

### 1.2 Create Resource Groups
```bash
az group create -n $IMAGE_RG -l $LOCATION
az group create -n $TEMP_RG -l $LOCATION
```

### 1.3 Create Service Principal
```bash
az ad sp create-for-rbac \
  --name "sp-packer-terraform-poc" \
  --role Contributor \
  --scopes /subscriptions/$SUBID/resourceGroups/$IMAGE_RG \
          /subscriptions/$SUBID/resourceGroups/$TEMP_RG \
  --sdk-auth
```

**Save the output!** You'll need:
- `clientId`
- `clientSecret`
- `tenantId`
- `subscriptionId`

## Step 2: Build Custom Image with Packer

```bash
cd packer/ubuntu

# Initialize Packer plugins
packer init .

# Validate the template
packer validate \
  -var "subscription_id=$SUBID" \
  -var "tenant_id=<TENANT_ID>" \
  -var "client_id=<CLIENT_ID>" \
  -var "client_secret=<CLIENT_SECRET>" \
  .

# Build the image
packer build \
  -var "subscription_id=$SUBID" \
  -var "tenant_id=<TENANT_ID>" \
  -var "client_id=<CLIENT_ID>" \
  -var "client_secret=<CLIENT_SECRET>" \
  .
```

**Result:** Managed Image `img-ubuntu-22` in `rg-image-poc`

## Step 3: Deploy VM with Terraform

### 3.1 Update terraform.tfvars
Edit `terraform/envs/dev/terraform.tfvars` with your values.

### 3.2 Deploy
```bash
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file="envs/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="envs/dev/terraform.tfvars" -auto-approve
```

### 3.3 Connect to VM
```bash
# Get outputs
terraform output public_ip
terraform output -raw admin_password

# SSH into VM
ssh azureuser@<PUBLIC_IP>
```

## Step 4: Cleanup

```bash
# Destroy Terraform resources
cd terraform
terraform destroy -var-file="envs/dev/terraform.tfvars" -auto-approve

# Delete resource groups (optional - removes everything including image)
az group delete -n $IMAGE_RG --yes --no-wait
az group delete -n $TEMP_RG --yes --no-wait
```

## Security Notes

- The Service Principal credentials should be stored securely (Azure Key Vault, environment variables)
- The NSG is configured to allow SSH only from specified IPs
- For production, use Azure Bastion instead of public IPs
- Consider using Azure Key Vault for VM passwords

## Optional: Enable RDP

1. Uncomment the `xrdp.sh` provisioner in `ubuntu.pkr.hcl`
2. Uncomment the RDP security rule in `main.tf`
3. Rebuild the image and redeploy the VM
