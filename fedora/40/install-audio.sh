#!/bin/bash
# ---------------------------
# This is a bash script for configuring Fedora 40 for pro audio USING PIPEWIRE.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# wget -O ~/install-audio.sh https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/fedora/40/install-audio.sh && chmod +x ~/install-audio.sh && ~/install-audio.sh

# Exit if any command fails
set -e

# TODO: Copy jack.conf to ~/.config/pipewire/jack.conf and make appropriate changes
# mkdir -p ~/.config/pipewire
# sudo cp /usr/share/pipewire/jack.conf ~/.config/pipewire/jack.conf

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}


# ---------------------------
# Update our system
# ---------------------------
notify "Update the system"
sudo dnf update


# ---------------------------
# limits
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
# ---------------------------
notify "Modify limits.d/audio.conf"
echo '@audio - rtprio 90
@audio - memlock unlimited' | sudo tee -a /etc/security/limits.d/audio.conf


# ---------------------------
# sysctl.conf
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
# ---------------------------
notify "Modify /etc/sysctl.conf"
echo 'fs.inotify.max_user_watches=600000' | sudo tee -a /etc/sysctl.conf


# ---------------------------
# Add the user to the audio group
# ---------------------------
notify "Add ourselves to the audio group"
sudo usermod -a -G audio $USER


# ---------------------------
# REAPER
# Note: The instructions below will create a PORTABLE REAPER installation
# at ~/REAPER.
# ---------------------------
notify "REAPER"
wget -O reaper.tar.xz http://reaper.fm/files/7.x/reaper729_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
./reaper/reaper_linux_x86_64/install-reaper.sh --install ~/ --integrate-desktop
rm -rf ./reaper
rm reaper.tar.xz
touch ~/REAPER/reaper.ini


# ------------------------------------------------------------------------------------
# Wine and yabridge
# https://copr.fedorainfracloud.org/coprs/patrickl/wine-tkg/
# ------------------------------------------------------------------------------------

sudo dnf install realtime-setup -y
sudo systemctl enable realtime-setup.service
sudo systemctl enable realtime-entsk.service
sudo usermod -a -G realtime $(whoami)

sudo dnf copr enable patrickl/wine-tkg -y
sudo dnf copr enable patrickl/wine-mono -y
sudo dnf copr enable patrickl/mingw-wine-gecko -y
sudo dnf copr enable patrickl/vkd3d -y
sudo dnf copr enable patrickl/wine-dxvk -y
sudo dnf copr enable patrickl/winetricks -y
sudo dnf copr enable patrickl/yabridge -y

sudo dnf install wine wine-mono mingw32-wine-gecko mingw64-wine-gecko libvkd3d wine-dxvk* winetricks yabridge -y --refresh

echo "# Audio: wine and yabridge" >> ~/.bashrc
echo "export WINEESYNC=1" >> ~/.bashrc
echo "export WINEFSYNC=1" >> ~/.bashrc

# Winetricks
sudo dnf install winetricks -y
winetricks corefonts

# Create common VST paths for yabridge
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