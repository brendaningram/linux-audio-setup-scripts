#!/bin/bash
# ---------------------------
# This is a bash script for configuring Fedora for pro audio USING PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O - https://raw.githubusercontent.com/brendaningram/install-scripts/main/fedora/35/install-audio.sh | bash

# Exit if any command fails
set -e

# TODO: Copy jack.conf to ~/.config/pipewire/jack.conf and make appropriate changes
# mkdir -p ~/.config/pipewire
# sudo cp /usr/share/pipewire/jack.conf ~/.config/pipewire/jack.conf

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# ------------------------------------------------------------------------------------
# Install packages
# ------------------------------------------------------------------------------------
notify "Update our system"
sudo dnf update

# Audio
notify "Install audio packages"
# NOTE: Fedora has a good Pipewire setup OOTB.
# Not much needs to be done here.

#echo "/usr/lib/pipewire-0.3/jack" | sudo tee /etc/ld.so.conf.d/pipewire-jack.conf
#sudo ldconfig


# ---------------------------
# grub
# threadirqs = TODO
# cpufreq.default_governor=performance = TODO
# ---------------------------
notify "Modify GRUB options"
#sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet threadirqs cpufreq.default_governor=performance"/g' /etc/default/grub
#sudo grub-mkconfig -o /boot/grub/grub.cfg


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
echo 'fs.inotify.max_user_watches=600000' | sudo tee -a /etc/sysctl.conf


# ---------------------------
# Add the user to the audio group
# ---------------------------
notify "Add ourselves to the audio group"
sudo usermod -a -G audio $USER


# ------------------------------------------------------------------------------------
# Bitwig
# ------------------------------------------------------------------------------------
notify "Install Bitwig"
flatpak install flathub com.bitwig.BitwigStudio


# ------------------------------------------------------------------------------------
# Reaper
# ------------------------------------------------------------------------------------
notify "Install Reaper"
wget -O reaper.tar.xz http://reaper.fm/files/6.x/reaper645_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
sudo ./reaper/reaper_linux_x86_64/install-reaper.sh --install /opt --integrate-desktop --usr-local-bin-symlink
rm -rf ./reaper
rm reaper.tar.xz


# ------------------------------------------------------------------------------------
# Wine (staging)
# ------------------------------------------------------------------------------------

sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/35/winehq.repo
sudo dnf install winehq-staging -y

# winetricks
# TODO: Move it to a more suitable location
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks

# Base wine packages required for proper plugin functionality
./winetricks corefonts


# ------------------------------------------------------------------------------------
# yabridge
# ------------------------------------------------------------------------------------

# BLOCKER: yabridge isn't available on Fedora 35 yet
sudo dnf copr enable patrickl/yabridge
sudo dnf install yabridge

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
