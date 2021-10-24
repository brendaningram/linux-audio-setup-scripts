#!/bin/bash
# ---------------------------
# This is a bash script for configuring KDE Neon as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningramaudio/install-scripts/main/neon/focal/install-desktop.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}


# ---------------------------
# Update our system
# ---------------------------
notify "Update the system"
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoremove -y


# ---------------------------
#
# ---------------------------
notify "Install applications"

# Useful utilities
sudo apt install git vim -y

# Timeshift allows us to take snapshots of our system at points in time.
# This means if something happens to our system to break it, we can
# roll back to a previously working snapshot.
sudo apt install timeshift -y

# Image editing
# Use this instead of: Photoshop
sudo apt install krita -y

# Photo management
# Use this instead of: Lightroom
sudo apt install digikam -y

# Video editing
# Use this instead of: Davinci Resolve, iMovie
sudo apt install kdenlive -y

# Screen recording and streaming
# OBS works on Mac, Windows, and Linux
# It is the universally accepted application for streaming
sudo apt install obs-studio -y

# Text editing
# Kate is a more powerful (but still lightweight) version of kwrite.
sudo apt install kate -y

# Libreoffice
# The version in KDE Neon is out of date.
# Install the latest version from the Libreoffice website.
wget https://mirror.aarnet.edu.au/pub/tdf/libreoffice/stable/7.2.2/deb/x86_64/LibreOffice_7.2.2_Linux_x86-64_deb.tar.gz
tar -xf LibreOffice_7.2.2_Linux_x86-64_deb.tar.gz
sudo apt install ./LibreOffice_7.2.2.2_Linux_x86-64_deb/DEBS/*.deb
rm -rf ./LibreOffice_7.2.2.2_Linux_x86-64_deb
rm LibreOffice_7.2.2_Linux_x86-64_deb.tar.gz

# TODO: Other applications will be added here soon.
