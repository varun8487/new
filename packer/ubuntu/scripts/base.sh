#!/usr/bin/env bash
# =============================================================================
# Base Provisioning Script for Ubuntu 22.04 LTS
# This script installs common packages and performs basic configuration
# =============================================================================

set -euo pipefail

echo "=========================================="
echo "Starting base provisioning..."
echo "=========================================="

# Wait for cloud-init to complete
echo "Waiting for cloud-init to complete..."
cloud-init status --wait || true

# Update package lists and upgrade existing packages
echo "Updating system packages..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# Install common utilities
echo "Installing common utilities..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    jq \
    unzip \
    htop \
    net-tools \
    vim \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Enable password authentication for SSH (for POC only - disable in production!)
echo "Configuring SSH..."
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Create image build info file
echo "Creating image build info..."
cat << EOF | sudo tee /etc/image-build-info
========================================
Custom Ubuntu 22.04 LTS Image
========================================
Build Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Packer Version: ${PACKER_BUILD_NAME:-unknown}
Kernel Version: $(uname -r)
========================================
EOF

# Cleanup
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /tmp/*

echo "=========================================="
echo "Base provisioning complete!"
echo "=========================================="
