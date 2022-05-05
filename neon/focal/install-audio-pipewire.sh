#!/bin/bash
# ---------------------------
# This is a bash script for configuring KDE Neon (based on Ubuntu 20.04) for pro audio.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/neon/focal/install-audio-pipewire.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}


# Coming soon