#!/bin/bash

# ------------------------------------------------------------------------------------
# This is a bash script for configuring KDE Neon as a usable Windows or Mac replacement.
# Whereas the audio scripts are designed to be run in their entirety, this script is
# more of a guide - please pick and choose the pieces that are relevant to you.
# ------------------------------------------------------------------------------------

# Exit if any command fails
set -e

notify () {
  echo "--------------------------------------------------------------------"
  echo $1
  echo "--------------------------------------------------------------------"
}


# ------------------------------------------------------------------------------------
# Add ourselves as sudo
# NOTE: My machine is physically secured, so I specify NOPASSWD for sudo convenience.
# If you have security concerns, don't do this.
# ------------------------------------------------------------------------------------
notify "Add $USER to sudoers.d"
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER


# ------------------------------------------------------------------------------------
# Update our system
# ------------------------------------------------------------------------------------
notify "Update the system"
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y


# ------------------------------------------------------------------------------------
# GRUB background image
# ------------------------------------------------------------------------------------
notify "Set a nice Debian GRUB image"
wget https://raw.githubusercontent.com/brendaningram/linux-audio-setup-scripts/main/debian/debian-wallpaper.tga
sudo mv debian-wallpaper.tga /boot/grub/
sudo update-grub


# ------------------------------------------------------------------------------------
# Desktop environment
# https://wiki.debian.org/gnome
# ------------------------------------------------------------------------------------

# Cleanup
notify "Application cleanup"
read -p "Would you like a minimalist system? Note this will remove gnome games, maps, weather, shotwell etc. (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo apt remove gnome-games rhythmbox gnome-weather gnome-maps totem gnome-music shotwell evolution -y
fi


notify "Install applications"

# Firmware
# We add the contrib and non-free repositories above to give us the broadest range of firmware
#sudo apt install firmware-linux -y

# Useful utilities
sudo apt install git vim nfs-common -y

# Timeshift allows us to take snapshots of our system at points in time.
# This means if something happens to our system to break it, we can
# roll back to a previously working snapshot.
sudo apt install timeshift -y

# Image editing
# Use this instead of: Photoshop
sudo apt install krita -y

# Vector editing
# Use this instead of: Illustrator
sudo apt install inkscape -y

# Photo management
# Use this instead of: Lightroom
sudo apt install digikam -y

# Video editing
# Use this instead of: Davinci Resolve, iMovie
sudo apt install kdenlive mediainfo handbrake -y

# Video playing
sudo apt install vlc -y

# Screen recording and streaming
# OBS works on Mac, Windows, and Linux
# It is the universally accepted application for streaming
sudo apt install obs-studio -y


# Games
#sudo apt install 0ad -y

# Copying music CD's
#sudo apt install asunder vorbis-tools -y

# Evaluating
#sudo apt install gnucash xournalpp


# ------------------------------------------------------------------------------------
# Firefox
# ------------------------------------------------------------------------------------
notify "Firefox"
read -p "Would you like to use the latest Firefox from Mozilla instead of Firefox ESR from Debian (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt remove firefox-esr -y
    wget -q -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
    sudo tar -C /opt -xf firefox.tar.bz2
    rm firefox.tar.bz2

    echo "[Desktop Entry]
    Name=Firefox Stable
    Comment=Web Browser
    Exec=/opt/firefox/firefox %u
    Terminal=false
    Type=Application
    Icon=/opt/firefox/browser/chrome/icons/default/default128.png
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
    StartupNotify=true" | sudo tee /usr/share/applications/firefox.desktop

    sudo rm /usr/local/bin/firefox
    sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200 && sudo update-alternatives --set x-www-browser /opt/firefox/firefox
fi


# ------------------------------------------------------------------------------------
# Google Chrome
# ------------------------------------------------------------------------------------
notify "Google Chrome"
read -p "Would you like to install Google Chrome (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -q -O chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt install ./chrome.deb -y
    rm chrome.deb
fi


# ------------------------------------------------------------------------------------
# VS Code
# ------------------------------------------------------------------------------------
notify "VS Code"
read -p "Install VS Code (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -O -L https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
    wget -qO vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
    sudo apt install ./vscode.deb -y
    rm vscode.deb
fi


# ------------------------------------------------------------------------------------
# VS Codium
# ------------------------------------------------------------------------------------
notify "VSCodium"
read -p "Install VSCodium (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install codium -y
fi


# ------------------------------------------------------------------------------------
# Dropbox
# ------------------------------------------------------------------------------------
notify "Dropbox"
read -p "Install Dropbox (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -O dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb
    sudo apt install ./dropbox.deb -y
    rm ./dropbox.deb
fi




# ------------------------------------------------------------------------------------
# Gnome config
# ------------------------------------------------------------------------------------

notify "The following section contains useful Gnome settings. It is not recommended to run this section, rather please review the script file yourself and manually run the sections you need."
read -p "Run the Gnome settings section (Y/N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then

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

  # Minimize and Maximize buttons
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

  # 12 hour time display
  gsettings set org.gnome.desktop.interface clock-format 12h

  # Dark theme
  gsettings set org.gnome.desktop.interface gtk-theme Adwaita
  #gsettings set org.gnome.desktop.interface gtk-theme gnome-professional-40.1

  # Default calendar
  gsettings set org.gnome.desktop.default-applications.office.calendar exec gnome-calendar

  # Don't suspend when plugged in
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

  # Mouse
  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

  # Touchpad
  gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
  gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
  gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click  true
  gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
  gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

  # Terminal
  gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode 'tab'
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ visible-name 'Default'
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ login-shell false
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 140
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 40
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollbar-policy 'never'

fi


notify "Done!"





# TODO: 
# linux linux-firmware intel-ucode
# latest firefox
# chrome?
# vs code
# makemkv
# moka icon and gnome-tweaks
# OBS needs this set in order to be able to access wayland screens
#echo "export QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/profile
