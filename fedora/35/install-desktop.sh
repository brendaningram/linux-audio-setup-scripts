#!/bin/bash
# ---------------------------
# This is a bash script for configuring Fedora as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/install-scripts/main/fedora/35/install-desktop.sh | bash

# Exit if any command fails
set -e

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# Ensure we run this script from the local disk
cd ~/


flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.obsproject.Studio

flatpak install flathub org.kde.krita

flatpak install flathub org.kde.digikam

flatpak install flathub fr.handbrake.ghb

flatpak install flathub org.kde.kdenlive

flatpak install flathub org.videolan.VLC

flatpak install flathub com.makemkv.MakeMKV





# ------------------------------------------------------------------------------------
# Core install
# ------------------------------------------------------------------------------------
sudo dnf update

# Browsers
sudo dnf install google-chrome-stable


sudo dnf install timeshift




# Copying music CD's
#sudo pacman -S asunder vorbis-tools --noconfirm

# Resolve Gnome Software "no plugin could handle get-updates"
#sudo pacman -S gnome-software-packagekit-plugin --noconfirm

# OBS needs this set in order to be able to access wayland screens
#echo "export QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/profile




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

notify "Your Fedora desktop setup is complete!"

notify "Now install audio by running install-audio from this Github repository."
