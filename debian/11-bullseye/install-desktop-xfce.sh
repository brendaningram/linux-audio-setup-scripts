#!/bin/bash
# ---------------------------
# This is a bash script for configuring Debian 11 (bullseye) for pro audio.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/debian/11-bullseye/install-audio.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}


# i915 firmware
#git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
#sudo cp -r ./linux-firmware/i915 /lib/firmware
#sudo update-initramfs -u -k all


# ---------------------------
# Update our system
# ---------------------------
notify "Update the system"
sudo apt update && sudo apt dist-upgrade -y


# ------------------------------------------------------------------------------------
# GRUB background image
# ------------------------------------------------------------------------------------
notify "Set a nice Debian GRUB image"
wget https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/debian/debian-wallpaper.tga
sudo mv debian-wallpaper.tga /boot/grub/
sudo update-grub


# ---------------------------
# Fix screen tearing
# Note: This is for Intel graphics
# Review https://techstop.github.io/fix-screen-tearing-xfce/
# for other graphics systems.
# ---------------------------
notify "Update the system"
echo 'Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
  Option "TearFree" "true"
EndSection' | sudo tee /usr/share/X11/xorg.conf.d/10-intel.conf


# ---------------------------
# Install required and/or useful packages
# git
# vim
# nfs-common: Mounting NFS volumes
# gvfs-backends: Thunar volume management
# moka-icon-theme: Nice(r) icon theme
# greybird-gtk-theme: Nice(r) UI theme
# ---------------------------
sudo apt install git vim nfs-common gvfs-backends moka-icon-theme greybird-gtk-theme 


# ---------------------------
# Install Flatpak
# Some applications on Debian 11 are just too far out of date
# For my use, I require:
# kdenlive
# krita
# OBS
# ---------------------------
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub org.kde.krita
flatpak install flathub org.kde.kdenlive
# flatpak install flathub com.obsproject.Studio



# ---------------------------
# Automount NFS volume(s)
# ---------------------------
sudo mkdir -p /mnt/NAS
echo "[Unit]
  Description=NAS:mount
  Requires=network-online.target
  After=network-online.service

[Mount]
  What=192.168.20.15:/volume1/Data
  Where=/mnt/NAS
  Options=
  Type=nfs

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.mount
echo "[Unit]
  Description=NAS:Automount
  Requires=network-online.target
  After=network-online.service

[Automount]
  Where=/mnt/NAS
  TimeoutIdleSec=86400

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.automount
sudo systemctl enable mnt-NAS.automount
sudo systemctl start mnt-NAS.automount


# ****************************************************************************************************************************
# bi_split_obs_recording
# When I record a video using OBS I have 4 elements
# 1. The video (screen recording)
# 2. Voice over dialogue recorded using the microphone
# 3. DAW audio
# 4. Desktop audio
# When I edit the video for publishing I want to ensure the audio quality is maximised.
# To do that I need to import the 3 separate audio streams into REAPER and process them.
# This gives me separate video and audio files.
# ****************************************************************************************************************************
bi_split_obs_recording () {
    filename=$(echo "$@" | cut -f 1 -d '.')
    ffmpeg -i $filename.mkv \
    -map 0:v -c copy $filename-vid.mkv \
    -map 0:a:0 -c copy $filename-vod.aac \
    -map 0:a:1 -c copy $filename-daw.aac \
    -map 0:a:2 -c copy $filename-dsk.aac;

for a in *.aac; do ffmpeg -i "$a" "${a%.aac}.wav"; done
rm *.aac;
}
alias bobs=bi_split_obs_recording


# ---------------------------
# FINISHED!
# ---------------------------
notify "Done."
