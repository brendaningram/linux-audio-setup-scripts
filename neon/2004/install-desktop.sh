#!/bin/bash

# ------------------------------------------------------------------------------------
# This is a bash script for configuring KDE Neon as a usable Windows or Mac replacement.
# Whereas the audio scripts are designed to be run in their entirety, this script is
# more of a guide - please pick and choose the pieces that are relevant to you.
# ------------------------------------------------------------------------------------

# Exit if any command fails
set -e

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}


# ------------------------------------------------------------------------------------
# Add ourselves as sudo
# NOTE: My machine is physically secured, so I specify NOPASSWD for sudo convenience.
# If you have security concerns, don't do this.
# ------------------------------------------------------------------------------------
notify "Add $USER to sudoers.d"
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER


# ------------------------------------------------------------------------------------
# Install i915 firmware
# NOTE: ONLY RUN THIS IF YOU HAVE INTEL i915 FIRMWARE REQUIREMENTS
# ------------------------------------------------------------------------------------
notify "Install i915 firmware"
git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
sudo cp -r ./linux-firmware/i915 /lib/firmware
sudo update-initramfs -u -k all
rm -rf ./linux-firmware


# ------------------------------------------------------------------------------------
# Update our system
# ------------------------------------------------------------------------------------
notify "Update the system"
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoremove -y


# ------------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------------
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

# Vector editing
# Use this instead of: Illustrator
sudo apt install inkscape -y

# Photo management
# Use this instead of: Lightroom
sudo apt install digikam -y

# Video editing
# Use this instead of: Davinci Resolve, iMovie
sudo apt install kdenlive mediainfo -y

# Screen recording and streaming
# OBS works on Mac, Windows, and Linux
# It is the universally accepted application for streaming
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt install obs-studio -y

# Text editing
# Kate is a more powerful (but still lightweight) version of kwrite.
sudo apt install kate -y

# Libreoffice
wget -q -O libreoffice.tar.gz "https://mirror.aarnet.edu.au/pub/tdf/libreoffice/stable/7.4.2/deb/x86_64/LibreOffice_7.4.2_Linux_x86-64_deb.tar.gz"
mkdir ./libreoffice
tar -C ./libreoffice -xf libreoffice.tar.gz
sudo apt install ./libreoffice/LibreOffice_7.4.2.3_Linux_x86-64_deb/DEBS/*.deb
rm -rf ./libreoffice
rm libreoffice.tar.gz


# ------------------------------------------------------------------------------------
# Google Chrome
# ------------------------------------------------------------------------------------
notify "Google Chrome"
read -p "Would you like to install Google Chrome (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -q -O chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt install ./chrome.deb -y
    rm chrome.deb
fi


# ------------------------------------------------------------------------------------
# VS Code
# ------------------------------------------------------------------------------------
notify "VS Code"
read -p "Install VS Code (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -O -L https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
    wget -qO vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
    sudo apt install ./vscode.deb -y
    rm vscode.deb
fi


# ------------------------------------------------------------------------------------
# VS Codium
# ------------------------------------------------------------------------------------
notify "VSCodium"
read -p "Install VSCodium (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install codium -y
fi


# ------------------------------------------------------------------------------------
# Dropbox
# ------------------------------------------------------------------------------------
notify "Dropbox"
read -p "Install Dropbox (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -O dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb
    sudo apt install ./dropbox.deb -y
    rm ./dropbox.deb
fi
