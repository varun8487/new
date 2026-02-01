# =============================================================================
# Terraform Configuration for Azure VM from Custom Packer Image
# =============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.114"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# Uses ARM_* environment variables automatically:
#   ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
# -----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.50.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.50.1.0/24"]
}

# -----------------------------------------------------------------------------
# Network Security Group
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH from specified IPs
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  # Uncomment for RDP access (only for POC - use Azure Bastion in production)
  # security_rule {
  #   name                       = "Allow-RDP"
  #   priority                   = 110
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "3389"
  #   source_address_prefixes    = var.allowed_rdp_ips
  #   destination_address_prefix = "*"
  # }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Public IP Address
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Network Interface
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

# Associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -----------------------------------------------------------------------------
# Reference the Packer-built Managed Image
# -----------------------------------------------------------------------------
data "azurerm_image" "packer_img" {
  name                = var.managed_image_name
  resource_group_name = var.image_rg
}

# -----------------------------------------------------------------------------
# Random Password for VM Admin
# -----------------------------------------------------------------------------
resource "random_password" "admin" {
  length           = 18
  special          = true
  override_special = "!@#$%&*()-_=+[]{}|;:,.<>?"
}

# -----------------------------------------------------------------------------
# Linux Virtual Machine
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name_prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  source_image_id = data.azurerm_image.packer_img.id

  os_disk {
    name                 = "${var.name_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  tags = var.tags
}
