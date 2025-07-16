#!/bin/bash
# ---------------------------
# This is a bash script for configuring Debian 13 (trixie) for pro audio USING PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O ~/install-audio.sh https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/debian/13/install-audio.sh && chmod +x ~/install-audio.sh && ~/install-audio.sh

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
sudo apt modernize-sources -y
sudo apt update && sudo apt upgrade -y


# ---------------------------
# Install Liquorix kernel
# https://liquorix.net/
# ---------------------------
sudo apt install curl -y
curl 'https://liquorix.net/add-liquorix-repo.sh' | sudo bash
sudo apt install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y


# ---------------------------
# Pipewire
# https://wiki.debian.org/PipeWire
# NOTE: If you don't have any audio coming from your system, it is possible that the hardware
# channels in your audio interface are muted. In that case, run alsamixer, press F6 to select
# your audio interface, locate your main monitor channel, then press M to unmute.
# You can then run sudo alsactl store to persist these changes.
# ---------------------------
notify "Install pipewire"
sudo apt install pipewire-alsa pipewire-audio pipewire-audio-client-libraries pipewire-jack libspa-0.2-jack -y

# Tell all apps that use JACK to now use the Pipewire JACK
sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig

#sudo apt install qjackctl --no-install-recommends -y


# ---------------------------
# grub
# ---------------------------
notify "Modify GRUB options"
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet threadirqs cpufreq.default_governor=performance"/g' /etc/default/grub
sudo update-grub


# ---------------------------
# limits
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
# ---------------------------
notify "Modify limits.d/audio.conf"
echo '@pipewire - rtprio 90
@pipewire - memlock unlimited' | sudo tee -a /etc/security/limits.d/audio.conf


# ---------------------------
# sysctl.conf
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
# ---------------------------
notify "Modify /etc/sysctl.conf"
echo 'vm.swappiness=10
fs.inotify.max_user_watches=600000' | sudo tee -a /etc/sysctl.conf


# ---------------------------
# Add the user to the pipewire group
# ---------------------------
notify "Add ourselves to the pipewire group"
sudo usermod -a -G pipewire $USER


# ---------------------------
# REAPER
# Note: The instructions below will create a PORTABLE REAPER installation
# at ~/REAPER.
# ---------------------------
notify "REAPER"
wget -O reaper.tar.xz http://reaper.fm/files/7.x/reaper742_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
./reaper/reaper_linux_x86_64/install-reaper.sh --install ~/ --integrate-desktop
rm -rf ./reaper
rm reaper.tar.xz
touch ~/REAPER/reaper.ini


# ---------------------------
# Wine (staging)
# This is required for yabridge
# See https://wiki.winehq.org/Debian for additional information.
# ---------------------------
notify "Install Wine"
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources
sudo apt update
sudo apt install --install-recommends --allow-change-held-packages winehq-staging=9.21~trixie-1 wine-staging=9.21~trixie-1 wine-staging-amd64=9.21~trixie-1 wine-staging-i386=9.21~trixie-1 --allow-downgrades -y
sudo apt-mark hold winehq-staging wine-staging wine-staging-i386 wine-staging-amd64

# Winetricks
sudo apt install cabextract -y
mkdir -p ~/.local/share
wget -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
mv winetricks ~/.local/share
chmod +x ~/.local/share/winetricks
echo '' >> ~/.bash_aliases
echo '# Audio: winetricks' >> ~/.bash_aliases
echo 'export PATH="$PATH:$HOME/.local/share"' >> ~/.bash_aliases
. ~/.bash_aliases

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
wget -O yabridge.tar.gz https://github.com/robbert-vdh/yabridge/releases/download/5.1.1/yabridge-5.1.1.tar.gz
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

