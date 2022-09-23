#!/bin/bash
# ---------------------------
# This is a bash script for configuring KDE Neon (based on Ubuntu 20.04) for pro audio using JACK.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/neon/focal/install-audio-jack.sh | bash

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
sudo add-apt-repository ppa:damentz/liquorix && sudo apt-get update
sudo apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y


# ------------------------------------------------------------------------------------
# Cadence or qjackctl
# NOTE: I no longer recommend using Cadence. There is nothing wrong with it,
# however the same results can be achieved with qjackctl while retaining
# a minimal installation.
# NOTE: Select "YES" when asked to enable realtime privileges
# ------------------------------------------------------------------------------------
notify "Cadence or qjackctl"
read -p "Would you like to use Cadence (Y) for a simple user experience, or qjackctl (N) for a more powerful, and minimal experience (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  notify "Installing Cadence"
  sudo apt-get install apt-transport-https gpgv -y
  wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_10.0.3_all.deb
  sudo dpkg -i kxstudio-repos_10.0.3_all.deb
  rm kxstudio-repos_10.0.3_all.deb
  sudo apt update
  sudo apt install cadence -y
else
  notify "Installing qjackctl"
  sudo apt install qjackctl a2jmidid pulseaudio-module-jack pavucontrol -y
fi


# ---------------------------
# Modify GRUB options
# threadirqs:
# mitigations=off:
# cpufreq.default_governor=performance:
# ---------------------------
notify "Modify GRUB options"
sudo systemctl disable ondemand
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
# Add the user to the audio group
# ---------------------------
notify "Add user to the audio group"
sudo adduser $USER audio


# ---------------------------
# The i386 architecture is required for Bitwig and Wine
# ---------------------------
notify "Enable i386 architecture"
sudo dpkg --add-architecture i386
sudo apt update


# ---------------------------
# Install Bitwig
# ---------------------------
notify "Install Bitwig"
wget -O bitwig.deb https://downloads.bitwig.com/4.3.4/bitwig-studio-4.3.4.deb
sudo apt install ./bitwig.deb -y
rm bitwig.deb


# ---------------------------
# Install Reaper
# ---------------------------
wget -O reaper.tar.xz http://reaper.fm/files/6.x/reaper668_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
sudo ./reaper/reaper_linux_x86_64/install-reaper.sh --install /opt --integrate-desktop --usr-local-bin-symlink
rm -rf ./reaper
rm reaper.tar.xz


# ---------------------------
# Wine (staging)
# This is required for yabridge
# See https://wiki.winehq.org/Ubuntu for additional information.
# ---------------------------
notify "Install Wine"
sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo mv winehq.key /usr/share/keyrings/winehq-archive.key
wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
sudo mv winehq-focal.sources /etc/apt/sources.list.d/
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
wget -O yabridge.tar.gz https://github.com/robbert-vdh/yabridge/releases/download/3.8.1/yabridge-3.8.1.tar.gz
mkdir -p ~/.local/share
tar -C ~/.local/share -xavf yabridge.tar.gz
rm yabridge.tar.gz
echo '' >> ~/.bash_aliases
echo '# Audio: yabridge path' >> ~/.bash_aliases
echo 'export PATH="$PATH:$HOME/.local/share/yabridge"' >> ~/.bash_aliases
. ~/.bash_aliases

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
