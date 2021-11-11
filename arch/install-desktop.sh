#!/bin/bash
# ---------------------------
# This is a bash script for configuring Arch as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: See the README.md for instructions on installing Arch from scratch.
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningramaudio/install-scripts/main/arch/install-desktop.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# Ensure we run this script from the local disk
cd ~/

# ------------------------------------------------------------------------------------
# yay (AUR)
# ------------------------------------------------------------------------------------
sudo pacman -S base-devel git --noconfirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay


# ------------------------------------------------------------------------------------
# Core install
# ------------------------------------------------------------------------------------
sudo pacman -Syu

# Firmware (for example to enable wifi)
sudo pacman -S linux-firmware --noconfirm

# Utils
# xdg-desktop-portal is required for OBS to access pipewire displays
sudo pacman -S sudo vim nfs-utils wget which xdg-desktop-portal xdg-utils neofetch --noconfirm

# PDF
sudo pacman -S evince --noconfirm

# Browsers
sudo pacman -S firefox chromium --noconfirm
yay -S google-chrome --noconfirm

# Office and editing
sudo pacman -S libreoffice-fresh code --noconfirm

# Video
# opentimelineio: required for Kdenlive
sudo pacman -S digikam kdenlive opentimelineio vlc obs-studio handbrake --noconfirm

# Image and Graphics
sudo pacman -S digikam krita blender inkscape --noconfirm

# Copying music CD's
sudo pacman -S asunder vorbis-tools --noconfirm

# Resolve Gnome Software "no plugin could handle get-updates"
sudo pacman -S gnome-software-packagekit-plugin --noconfirm

# OBS needs this set in order to be able to access wayland screens
echo "export QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/profile

# Printers
sudo pacman -S cups system-config-printer --noconfirm
sudo systemctl enable cups

# Timeshift
yay -S timeshift --noconfirm

# MakeMKV
yay -S makemkv --noconfirm

# Dropbox
notify "Dropbox"
read -p "Install Dropbox? (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  yay -S nautilus-dropbox --noconfirm
fi

# pCloud
notify "pCloud"
read -p "Install pCloud (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  yay -S pcloud-drive --noconfirm
fi


# ------------------------------------------------------------------------------------
# QT theme
# Ensure that KDE/QT apps display nicely in Gnome
# ------------------------------------------------------------------------------------

sudo pacman -S qt6-base --noconfirm
yay -S adwaita-qt --noconfirm
# echo "QT_STYLE_OVERRIDE=adwaita" | sudo tee -a /etc/profile

# yay -S qgnomeplatform
# echo "QT_QPA_PLATFORMTHEME='gnome'" | sudo tee -a /etc/profile


# ------------------------------------------------------------------------------------
# Fonts
# ------------------------------------------------------------------------------------
sudo pacman -S ttf-hack ttf-anonymous-pro ttf-dejavu ttf-freefont ttf-liberation --noconfirm
yay -S ttf-font-awesome adobe-source-code-pro-fonts --noconfirm


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
#gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# 12 hour time display
gsettings set org.gnome.desktop.interface clock-format 12h

# Dark theme
#gsettings set org.gnome.desktop.interface gtk-theme Adwaita
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
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# Terminal
gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode: 'tab'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ visible-name 'Default'
#gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ login-shell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 140
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 40
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollbar-policy 'never'


# ------------------------------------------------------------------------------------
# Finish
# ------------------------------------------------------------------------------------

notify "Your Arch desktop setup is complete!"

notify "Now install audio by running either install-audio-jack or install-audio-pipewire from this Github repository."
