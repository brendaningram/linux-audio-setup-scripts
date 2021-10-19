#!/bin/bash
# ---------------------------
# This is a bash script for configuring Debian Bookworm as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# sudo apt install wget -y && wget -O - https://raw.githubusercontent.com/brendan-ingram-music/install-scripts/master/debian-bookworm-install.sh | bash

# exit when any command fails
set -e

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# TODO: 
# liquorix kernel
# linux linux-firmware intel-ucode
# latest firefox
# chrome?
# vs code
# makemkv
# moka icon and gnome-tweaks

echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free

deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free" | sudo tee /etc/apt/sources.list



# ------------------------------------------------------------------------------------
# Add ourselves as sudo
# NOTE: My machine is physically secured, so I specify NOPASSWD for sudo convenience.
# ------------------------------------------------------------------------------------
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

# ------------------------------------------------------------------------------------
# Core install
# ------------------------------------------------------------------------------------
sudo apt update && sudo apt full-upgrade

# Utils
sudo apt install vim git nfs-common firmware-linux neofetch -y

# Browsers
#sudo apt install firefox chromium -y

# Office and editing
sudo apt install libreoffice -y

# Audio
# pulseaudio-jack: To bridge pulse to jack using Cadence
# alsa-utils: For alsamixer (to increase base level of sound card)
# harvid: Ardour video
#sudo apt install cadence pulseaudio-jack alsa-utils ardour -y

# Video
sudo apt install digikam kdenlive vlc obs-studio handbrake -y

# Image and Graphics
sudo apt install digikam krita blender inkscape -y

# Games
sudo apt install 0ad -y

# Copying music CD's
sudo apt install asunder vorbis-tools -y

# Evaluating
#sudo apt install gnucash xournalpp

# Resolve Gnome Software "no plugin could handle get-updates"
#sudo apt install gnome-software-packagekit-plugin -y



# ------------------------------------------------------------------------------------
# Gnome config
# ------------------------------------------------------------------------------------

# How to list schemas
# gsettings list-schemas | sort

# How to list keys within a schema
# gsettings list-keys <schema>

# How to view current key value
# gsettings get <schema> <key>

# How to view the possible values of a key
# gsettings range <schema> <key>

# Show folders before files
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# Minimize button
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'


# 12 hour time display
gsettings set org.gnome.desktop.interface clock-format 12h

# Dark theme
gsettings set org.gnome.desktop.interface gtk-theme Adwaita
#gsettings set org.gnome.desktop.interface gtk-theme gnome-professional-40.1

# Default calendar
gsettings set org.gnome.desktop.default-applications.office.calendar exec gnome-calendar

# Don't suspend when plugged in
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type: 'nothing'

# Mouse
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

# Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click  true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# Terminal
gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode: 'tab'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ visible-name 'Default'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ login-shell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 140
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 40
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollbar-policy 'never'


# OBS needs this set in order to be able to access wayland screens
#echo "export QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/profile



# ------------------------------------------------------------------------------------
# Dropbox
# ------------------------------------------------------------------------------------
wget -O dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb
sudo apt install ./dropbox.deb -y
rm ./dropbox.deb

# ------------------------------------------------------------------------------------
# My personal config
# ------------------------------------------------------------------------------------

echo "[Unit]
  Description=NAS: mount
  Requires=network-online.target
  After=network-online.service

[Mount]
  What=192.168.20.15:/volume1/NAS
  Where=/mnt/NAS
  Options=
  Type=nfs

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.mount
  
  
echo "[Unit]
  Description=NAS: Automount
  Requires=network-online.target
  After=network-online.service

[Automount]
  Where=/mnt/NAS
  TimeoutIdleSec=86400

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.automount

sudo systemctl enable mnt-NAS.automount
sudo systemctl start mnt-NAS.automount


notify "Done!"

