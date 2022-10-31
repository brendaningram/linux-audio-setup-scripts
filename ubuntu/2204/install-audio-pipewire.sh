#!/bin/bash
# ---------------------------
# This is a bash script for configuring Ubuntu 22.04 (jammy) for pro audio using PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/ubuntu/2204/install-audio-pipewire.sh | bash

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


# ---------------------------
# Install the Liquorix kernel
# https://liquorix.net/
# ---------------------------
notify "Install the Liquorix kernel"
sudo add-apt-repository ppa:damentz/liquorix -y && sudo apt-get update
sudo apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y


# ------------------------------------------------------------------------------------
# Install the latest Pipewire
# https://pipewire-debian.github.io/pipewire-debian/
# ------------------------------------------------------------------------------------
notify "Install Pipewire"
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream -y
sudo add-apt-repository ppa:pipewire-debian/wireplumber-upstream -y
sudo apt update
sudo apt install gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,jack,alsa,v4l2,libcamera,locales,tests}} -y
sudo apt install wireplumber{,-doc} gir1.2-wp-0.4 libwireplumber-0.4-{0,dev} -y
systemctl --user --now disable pulseaudio.{socket,service}
systemctl --user mask pulseaudio
sudo cp -vRa /usr/share/pipewire /etc/
systemctl --user --now enable pipewire{,-pulse}.{socket,service} filter-chain.service
systemctl --user --now enable wireplumber.service


# ---------------------------
# Modify GRUB options
# threadirqs:
# mitigations=off:
# cpufreq.default_governor=performance:
# ---------------------------
notify "Modify GRUB options"
#sudo systemctl disable ondemand
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash threadirqs mitigations=off cpufreq.default_governor=performance"/g' /etc/default/grub
sudo update-grub


# ---------------------------
# sysctl.conf
# ---------------------------
notify "sysctl.conf"
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
echo 'vm.swappiness=10
fs.inotify.max_user_watches=600000' | sudo tee -a /etc/sysctl.conf


# ---------------------------
# audio.conf
# ---------------------------
notify "audio.conf"
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
echo '@audio - rtprio 90
@audio - memlock unlimited' | sudo tee -a /etc/security/limits.d/audio.conf


# ---------------------------
# Add the user to the audio group
# ---------------------------
notify "Add user to the audio group"
sudo adduser $USER audio


# ---------------------------
# Bitwig
# ---------------------------
notify "Bitwig"
read -p "Would you like to install Bitwig (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo dpkg --add-architecture i386
  sudo apt update
  wget -O bitwig.deb https://downloads.bitwig.com/4.4/bitwig-studio-4.4.deb
  sudo apt install ./bitwig.deb -y
  rm bitwig.deb
fi


# ---------------------------
# REAPER
# Note: The instructions below will create a PORTABLE REAPER installation
# at ~/REAPER.
# ---------------------------
notify "REAPER"
read -p "Would you like to install REAPER (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  wget -O reaper.tar.xz http://reaper.fm/files/6.x/reaper669_linux_x86_64.tar.xz
  mkdir ./reaper
  tar -C ./reaper -xf reaper.tar.xz
  ./reaper/reaper_linux_x86_64/install-reaper.sh --install ~/ --integrate-desktop
  rm -rf ./reaper
  rm reaper.tar.xz
  touch ~/REAPER/reaper.ini
fi


# ---------------------------
# Wine (staging)
# This is required for yabridge
# See https://wiki.winehq.org/Ubuntu and https://wiki.winehq.org/Winetricks for additional information.
# ---------------------------
notify "Install Wine"
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
sudo apt update
sudo apt install --install-recommends winehq-staging winetricks -y

# Base wine packages required for proper plugin functionality
winetricks corefonts

# Make a copy of .wine, as we will use this in the future as the base of
# new wine prefixes (when installing plugins)
cp -r ~/.wine ~/.wine-base


# ---------------------------
# Yabridge
# Detailed instructions can be found at: https://github.com/robbert-vdh/yabridge/blob/master/README.md
# ---------------------------
# NOTE: When you run this script, there may be a newer version of yabridge available.
# Check https://github.com/robbert-vdh/yabridge/releases and update the version numbers below if necessary
notify "Install yabridge"
wget -O yabridge.tar.gz https://github.com/robbert-vdh/yabridge/releases/download/4.0.2/yabridge-4.0.2.tar.gz
mkdir -p ~/.local/share
tar -C ~/.local/share -xavf yabridge.tar.gz
rm yabridge.tar.gz
echo '' >> ~/.bash_aliases
echo '# Audio: yabridge path' >> ~/.bash_aliases
echo 'export PATH="$PATH:$HOME/.local/share/yabridge"' >> ~/.bash_aliases
. ~/.bash_aliases

# libnotify-bin contains notify-send, which is used for yabridge plugin notifications.
sudo apt install libnotify-bin -y

# Create common VST paths
mkdir -p "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
mkdir -p "$HOME/.wine/drive_c/Program Files/Common Files/VST2"
mkdir -p "$HOME/.wine/drive_c/Program Files/Common Files/VST3"

# Add them into yabridge
yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST2"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"

# ---------------------------
# Install Windows VST plugins
# This is a manual step for you to run when you download plugins.
# First, run the plugin installer .exe file
# When the installer asks for a directory, make sure you select
# one of the directories above.

# VST2 plugins:
#   C:\Program Files\Steinberg\VstPlugins
# OR
#   C:\Program Files\Common Files\VST2

# VST3 plugins:
#   C:\Program Files\Common Files\VST3
# ---------------------------

# Each time you install a new plugin, you need to run:
# yabridgectl sync

# ---------------------------
# FINISHED!
# Now just reboot, and make music!
# ---------------------------
notify "Done - please reboot."
