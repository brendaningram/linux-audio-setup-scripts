# ---------------------------
# This is a bash script for configuring Arch as a usable Windows or Mac replacement.
# ---------------------------
# NOTE: See my guide at TODO for instructions on installing Arch from scratch.
# NOTE: Execute this script by running the following command on your system:
# sudo apt install wget -y && wget -O - https://raw.githubusercontent.com/brendan-ingram-music/install-scripts/master/arch-install.sh | bash

notify () {
  echo "----------------------------------"
  echo $1
  echo "----------------------------------"
}


# Set the full name of the user
chfn --full-name "$FULL_NAME" $USER

# ------------------------------------------------------------------------------------
# Add ourselves as sudo
# ------------------------------------------------------------------------------------
su -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"

# ------------------------------------------------------------------------------------
# Core install
# ------------------------------------------------------------------------------------
sudo pacman -Syu

# Firmware (for e.g. wifi)
sudo pacman -S linux-firmware --noconfirm

# Utils
# xdg-desktop-portal is required for OBS to access pipewire displays
sudo pacman -S sudo vim git nfs-utils wget which xdg-desktop-portal xdg-utils neofetch --noconfirm

# Browsers
sudo pacman -S firefox chromium --noconfirm

# Office and editing
sudo pacman -S libreoffice-fresh code --noconfirm

# Audio
# pulseaudio-jack: To bridge pulse to jack using Cadence
# alsa-utils: For alsamixer (to increase base level of sound card)
# harvid: Ardour video
#sudo pacman -S cadence pulseaudio-jack alsa-utils ardour --noconfirm

# Video
# opentimelineio: required for Kdenlive
sudo pacman -S digikam kdenlive opentimelineio vlc obs-studio handbrake --noconfirm

# Image and Graphics
sudo pacman -S digikam krita blender inkscape --noconfirm

# Games
sudo pacman -S 0ad --noconfirm

# Copying music CD's
sudo pacman -S asunder vorbis-tools --noconfirm

# Evaluating
#sudo pacman -S gnucash xournalpp

# Resolve Gnome Software "no plugin could handle get-updates"
sudo pacman -S gnome-software-packagekit-plugin --noconfirm

# ------------------------------------------------------------------------------------
# yay (AUR)
# ------------------------------------------------------------------------------------
sudo pacman -S base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd
rm -rf yay


# ------------------------------------------------------------------------------------
# AUR packages
# ------------------------------------------------------------------------------------

# Timeshift
yay -S timeshift --noconfirm

# MakeMKV
yay -S makemkv --noconfirm

# Dropbox
yay -S nautilus-dropbox --noconfirm

# pCloud
yay -S pcloud-drive --noconfirm


# ------------------------------------------------------------------------------------
# QT theme
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
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'


# 12 hour time display
gsettings set org.gnome.desktop.interface clock-format 12h

# Dark theme
gsettings set org.gnome.desktop.interface gtk-theme Adwaita
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
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click  true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# Terminal
gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode: 'tab'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ visible-name 'Default'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ login-shell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 140
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 40
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollbar-policy 'never'


# OBS needs this set in order to be able to access wayland screens
echo "export QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/profile

# ------------------------------------------------------------------------------------
# My personal config
# ------------------------------------------------------------------------------------

echo "[Unit]
  Description=NAS: mount
  Requires=network-online.target
  After=network-online.service

[Mount]
  What=192.168.20.15:/volume1/NAS
  Where=/mnt/NAS
  Options=
  Type=nfs

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.mount
  
  
echo "[Unit]
  Description=NAS: Automount
  Requires=network-online.target
  After=network-online.service

[Automount]
  Where=/mnt/NAS
  TimeoutIdleSec=86400

[Install]
  WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mnt-NAS.automount

sudo systemctl enable mnt-NAS.automount
sudo systemctl start mnt-NAS.automount


notify "Done!"

