#!/bin/bash
# ---------------------------
# This is a bash script for configuring Ubuntu 22.04 (jammy) for pro audio using PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/ubuntu/jammy/install-audio-pipewire.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}

# ---------------------------
# Update our system
# ---------------------------
notify "Update the system"
sudo apt update && sudo apt dist-upgrade -y


# COMING SOON