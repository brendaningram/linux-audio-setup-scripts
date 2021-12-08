#!/bin/bash

# WARNING: This script is a work in progress.

# ---------------------------
# This is a bash script for configuring Debian Bookworm as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/install-scripts/main/debian/12-bookworm/install-desktop-plasma.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# TODO: 
# prompt to ask about cloud - e.g. dropbox, pcloud
# k3b - cd ripping
# chrome?
# vs code
# makemkv
# pcloud-drive
# kde-config-tablet for Wacom tablet config

# iPhone connectivity
# kio-fuse ifuse gvfs-fuse ideviceinstaller libimobiledevice-utils python3-imobiledevice python3-plist libusbmuxd6 libusbmuxd-tools

# i915 firmware
#git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
#sudo cp -r ./linux-firmware/i915 /lib/firmware
#sudo update-initramfs -u -k all
#(then sudo apt-get update -y)

# ------------------------------------------------------------------------------------
# Add ourselves as sudo
# NOTE: My machine is physically secured, so I specify NOPASSWD for sudo convenience.
# ------------------------------------------------------------------------------------
notify "Add $USER to sudoers.d"
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER


# ------------------------------------------------------------------------------------
# Update sources
# ------------------------------------------------------------------------------------
notify "Update apt sources"
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free

deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free" | sudo tee /etc/apt/sources.list


# ------------------------------------------------------------------------------------
# Update
# ------------------------------------------------------------------------------------
notify "Update the system"
sudo apt update && sudo apt full-upgrade -y


# ------------------------------------------------------------------------------------
# GRUB background image
# ------------------------------------------------------------------------------------
wget https://raw.githubusercontent.com/brendaningram/install-scripts/main/debian/debian-wallpaper.tga
sudo mv debian-wallpaper.tga /boot/grub/
sudo update-grub


# ------------------------------------------------------------------------------------
# Desktop environment
# https://wiki.debian.org/KDE
# ------------------------------------------------------------------------------------
notify "Install plasma and applications"

# Plasma
sudo apt install plasma-desktop plasma-nm -y

# Login
sudo apt install sddm sddm-theme-breeze -y

# Plasma apps
sudo apt install dolphin ark konsole kwrite kcalc kde-spectacle okular -y

# Utils
sudo apt install vim git nfs-common firmware-linux -y

# Backup
sudo apt install timeshift -y

# Browsers
sudo apt install firefox-esr chromium -y

# Office and editing
sudo apt install libreoffice-plasma libreoffice -y

# Video
sudo apt install digikam kdenlive vlc obs-studio handbrake -y

# Image and Graphics
sudo apt install digikam krita blender inkscape -y


# ------------------------------------------------------------------------------------
# Firefox
# ------------------------------------------------------------------------------------
notify "Firefox"
read -p "Would you like to use the latest Firefox from Mozilla instead of Firefox ESR from Debian (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt remove firefox-esr -y
    wget -q -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
    sudo tar -C /opt -xf firefox.tar.bz2
    rm firefox.tar.bz2

    echo "[Desktop Entry]
    Name=Firefox Stable
    Comment=Web Browser
    Exec=/opt/firefox/firefox %u
    Terminal=false
    Type=Application
    Icon=/opt/firefox/browser/chrome/icons/default/default128.png
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
    StartupNotify=true" | sudo tee /usr/share/applications/firefox.desktop

    sudo rm /usr/local/bin/firefox
    sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200 && sudo update-alternatives --set x-www-browser /opt/firefox/firefox
fi

# TODO: Google Chrome
# https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb


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


notify "Done!"
