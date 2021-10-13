# ---------------------------
# This is a bash script for configuring Arch for pro audio.
# ---------------------------
# NOTE: Execute this script by running the following command on your system:
# sudo apt install wget -y && wget -O - https://raw.githubusercontent.com/brendan-ingram-music/install-scripts/master/arch-install-audio.sh | bash

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}

# ------------------------------------------------------------------------------------
# Install packages
# ------------------------------------------------------------------------------------
notify "Update our system"
sudo pacman -Syu

# Audio
# pulseaudio-jack: To bridge pulse to jack using Cadence
# alsa-utils: For alsamixer (to increase base level of sound card)
notify "Install audio packages"
sudo pacman -S cadence pulseaudio-jack alsa-utils ardour --noconfirm


# ---------------------------
# cpupower
# This tool allows our CPU to run at maximum performance
# On a laptop this will drain the battery faster,
# but will result in much better audio performance.
# ---------------------------
notify "Use performance CPU Governor"
sudo pacman -S cpupower --noconfirm
sudo systemctl enable cpupower.service
sudo sed -i 's/#governor='\''ondemand'\''/governor='\''performance'\''/g' /etc/default/cpupower


# ---------------------------
# grub
# ---------------------------
notify "Modify GRUB options"
#TODO:
#sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet threadirqs mitigations=off"/g' /etc/default/grub
sudo update-grub

#sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.+)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet a\"/g" ~/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet a"/g' ~/grub



# ---------------------------
# limits
# ---------------------------
notify "Modify limits.d/audio.conf"
# See https://wiki.linuxaudio.org/wiki/system_configuration for more information.
echo '@audio - rtprio 90       # maximum realtime priority
@audio - memlock unlimited  # maximum locked-in-memory address space (KB)' | sudo tee -a /etc/security/limits.d/audio.conf


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
yay -S bitwig-studio --noconfirm


# ------------------------------------------------------------------------------------
# Reaper
# ------------------------------------------------------------------------------------
notify "Install Reaper"
wget -O reaper.tar.xz http://reaper.fm/files/6.x/reaper636_linux_x86_64.tar.xz
mkdir ./reaper
tar -C ./reaper -xf reaper.tar.xz
sudo ./reaper/reaper_linux_x86_64/install-reaper.sh --install /opt --integrate-desktop --usr-local-bin-symlink
rm -rf ./reaper
rm reaper.tar.xz


# ------------------------------------------------------------------------------------
# Wine (staging)
# ------------------------------------------------------------------------------------

# Enable multilib
sudo cp /etc/pacman.conf /etc/pacman.conf.bak
cat /etc/pacman.conf.bak | tr '\n' '\f' | sed -e 's/#\[multilib\]\f#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\fInclude = \/etc\/pacman.d\/mirrorlist/g'  | tr '\f' '\n' | sudo tee /etc/pacman.conf
sudo pacman -Syyu

# Install wine-staging
sudo pacman -S wine-staging winetricks --noconfirm

# Downgrade to 6.14 (6.15 and 6.16 don't work with yabridge)
# Note: as of 10th October 2021 the correct number is 82 (6.14)
yay -S downgrade --noconfirm
sudo env DOWNGRADE_FROM_ALA=1 downgrade wine-staging

# ------------------------------------------------------------------------------------
# yabridge
# ------------------------------------------------------------------------------------

yay -S yabridge-bin --noconfirm

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
