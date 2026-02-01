#!/usr/bin/env bash
# =============================================================================
# XRDP + XFCE Desktop Provisioning Script
# This script installs XRDP and XFCE for remote desktop access
# =============================================================================

set -euo pipefail

echo "=========================================="
echo "Starting XRDP/XFCE installation..."
echo "=========================================="

# Update package lists
sudo apt-get update -y

# Install XFCE desktop environment and XRDP
echo "Installing XFCE desktop environment..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    dbus-x11

# Configure XRDP to use XFCE
echo "Configuring XRDP..."

# Set XFCE as the default session for all users
echo "xfce4-session" | sudo tee /etc/skel/.xsession

# Create xsession for existing azureuser if they exist
if id "azureuser" &>/dev/null; then
    echo "xfce4-session" | sudo -u azureuser tee /home/azureuser/.xsession
fi

# Fix Xwrapper permissions for XRDP
if [ -f /etc/X11/Xwrapper.config ]; then
    echo "Fixing Xwrapper configuration..."
    sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config || true
fi

# Configure XRDP to work with XFCE
sudo bash -c 'cat > /etc/xrdp/startwm.sh << EOF
#!/bin/sh
# xrdp session start script

if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi

# Start XFCE session
startxfce4
EOF'

sudo chmod +x /etc/xrdp/startwm.sh

# Enable and start XRDP service
echo "Enabling XRDP service..."
sudo systemctl enable xrdp
sudo systemctl restart xrdp

# Configure firewall if ufw is enabled
if command -v ufw &> /dev/null; then
    sudo ufw allow 3389/tcp || true
fi

echo "=========================================="
echo "XRDP/XFCE installation complete!"
echo "RDP will be available on port 3389"
echo "=========================================="
