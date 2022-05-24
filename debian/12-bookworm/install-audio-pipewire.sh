#!/bin/bash
# ---------------------------
# This is a bash script for configuring Debian 12 (bookworm) for pro audio USING PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/debian/12-bookworm/install-audio-pipewire.sh | bash

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
sudo apt update && sudo apt full-upgrade -y


# ---------------------------
# Liquorix kernel
# https://liquorix.net/
# ---------------------------
notify "Install the Liquorix kernel"
sudo apt install curl
curl 'https://liquorix.net/add-liquorix-repo.sh' | sudo bash
sudo apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y


# ---------------------------
# Pipewire
# https://wiki.debian.org/PipeWire
# NOTE: If you don't have any audio coming from your system, it is possible that the hardware
# channels in your audio interface are muted. In that case, run alsamixer, press F6 to select
# your audio interface, locate your main monitor channel, then press M to unmute.
# You can then run sudo alsactl store to persist these changes.
# ---------------------------
notify "Install pipewire"
sudo apt remove pipewire-media-session -y
sudo apt install pipewire pipewire-audio-client-libraries libspa-0.2-jack pipewire-pulse wireplumber -y

systemctl --user disable --now pipewire-media-session
systemctl --user enable --now wireplumber

#sudo apt install qjackctl --no-install-recommends -y

# Tell all apps that use JACK to now use the Pipewire JACK
sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig


# ---------------------------
# cpupower
# This tool allows our CPU to run at maximum performance
# On a laptop this will drain the battery faster,
# but will result in much better audio performance.
# ---------------------------
#notify "Use performance CPU Governor"
#sudo apt install linux-cpupower -y
#sudo systemctl enable cpupower.service
#sudo sed -i 's/#governor='\''ondemand'\''/governor='\''performance'\''/g' /etc/default/cpupower


# ---------------------------
# grub
# ---------------------------
notify "Modify GRUB options"
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet threadirqs cpufreq.default_governor=performance"/g' /etc/default/grub
sudo update-grub


# ---------------------------
# limits
# ---------------------------
notify "Modify limits.d/audio.conf"
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
echo '@audio - rtprio 90
@audio - memlock unlimited' | sudo tee -a /etc/security/limits.d/audio.conf


# ---------------------------
# sysctl.conf
# ---------------------------
notify "Modify /etc/sysctl.conf"
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
echo 'vm.swappiness=10
fs.inotify.max_user_watches=600000' | sudo tee -a /etc/sysctl.conf


# ---------------------------
# Add the user to the audio group
# ---------------------------
notify "Add ourselves to the audio group"
sudo usermod -a -G audio $USER


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
wget -O bitwig.deb https://downloads.bitwig.com/4.2.3/bitwig-studio-4.2.3.deb
sudo apt install ./bitwig.deb -y
rm bitwig.deb


# ---------------------------
# Install Reaper
# ---------------------------
notify "Install Reaper"
wget -O reaper.tar.xz http://reaper.fm/files/6.x/reaper658_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
sudo ./reaper/reaper_linux_x86_64/install-reaper.sh --install /opt --integrate-desktop --usr-local-bin-symlink
rm -rf ./reaper
rm reaper.tar.xz


# ---------------------------
# Wine
# Detailed instructions can be found at: https://wiki.winehq.org/Debian
# ---------------------------

mkdir -p ~/.local/share

# Install Wine (yabridge needs this)
notify "Install Wine Staging"
sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo mv winehq.key /usr/share/keyrings/winehq-archive.key
wget -nc https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
sudo mv winehq-bookworm.sources /etc/apt/sources.list.d/
sudo apt update
sudo apt install --install-recommends winehq-staging

# Winetricks
#sudo apt install winetricks zenity -y
wget -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
mv winetricks ~/.local/share
chmod +x ~/.local/share/winetricks
echo '' >> ~/.bash_aliases
echo '# Audio: winetricks' >> ~/.bash_aliases
echo 'export PATH="$PATH:$HOME/.local/share"' >> ~/.bash_aliases
. ~/.bash_aliases

# NOTE: On first run wine will set up your wineprefix.
# NOTE: You may see a dialog to install MONO - click "Install".
sudo apt-get install cabextract -y
winetricks corefonts

# Make a copy of .wine, as we will use this in the future as the base of
# new wine prefixes (when installing plugins)
cp -r ~/.wine ~/.wine-base

# ---------------------------
# Yabridge
# Detailed instructions can be found at: https://github.com/robbert-vdh/yabridge/blob/master/README.md
# NOTE: When you run this script, there may be a newer version of yabridge available.
# Check https://github.com/robbert-vdh/yabridge/releases and update the version numbers below if necessary
# ---------------------------
notify "Install yabridge"
wget -O yabridge.tar.gz https://github.com/robbert-vdh/yabridge/releases/download/3.8.1/yabridge-3.8.1.tar.gz
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
