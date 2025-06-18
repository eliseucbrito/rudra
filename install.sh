#!/usr/bin/env bash

# Prevent running the script directly as root
if [[ $EUID -eq 0 ]]; then
  echo "This script must be run as a normal user (using sudo when necessary)."
  exit 1
fi

# Set variables for directories and files
# Using 'getent passwd $SUDO_USER | cut -d: -f6' is more robust than 'eval echo ~$SUDO_USER'
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
RUDRA_DIR="$USER_HOME/rudra"
HARDWARE_CONFIG_DIR="$RUDRA_DIR/hosts/default"
HARDWARE_CONFIG_FILE="$HARDWARE_CONFIG_DIR/hardware-configuration.nix"
SYSTEM_HARDWARE_CONFIG="/etc/nixos/hardware-configuration.nix"

# Ensure the target directory exists
mkdir -p "$HARDWARE_CONFIG_DIR" || { echo "Failed to create directory $HARDWARE_CONFIG_DIR"; exit 1; }

# Main logic for hardware-configuration.nix
if [ -f "$HARDWARE_CONFIG_FILE" ]; then
   echo "The 'hardware-configuration.nix' file already exists in your directory. No action needed."
else
   echo "The 'hardware-configuration.nix' file was not found."
   if [ -f "$SYSTEM_HARDWARE_CONFIG" ]; then
      echo "Copying existing hardware configuration from $SYSTEM_HARDWARE_CONFIG..."
      sudo cp "$SYSTEM_HARDWARE_CONFIG" "$HARDWARE_CONFIG_FILE" || { echo "Failed to copy hardware configuration."; exit 1; }
      # Adjust permissions for the user who ran sudo
      sudo chown $SUDO_USER:$SUDO_USER "$HARDWARE_CONFIG_FILE"
   else
      echo "No existing hardware configuration found. Generating a new one..."
      sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG_FILE" || { echo "Failed to generate new hardware configuration."; exit 1; }
      # Adjust permissions
      sudo chown $SUDO_USER:$SUDO_USER "$HARDWARE_CONFIG_FILE"
      echo "New hardware configuration generated successfully."
   fi
fi

# Change to the flake directory
cd "$RUDRA_DIR" || { echo "Failed to enter directory $RUDRA_DIR"; exit 1; }

# Rebuild NixOS configuration
echo "Starting NixOS configuration rebuild..."
sudo nixos-rebuild switch --flake .#default || { echo "Failed to rebuild NixOS configuration."; exit 1; }

echo "Script completed successfully."