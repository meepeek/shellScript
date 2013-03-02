#!/bin/sh
# Joke's Ubuntu 9.10 preinstall script

# Update Kernel
sudo apt-get install linux-headers-$(uname -r)

# VirtualBox 3.1 dependencies
sudo ./apt-get -y install libqt4-network libqtcore4 libqt4-opengl libqtgui4

sudo apt-get -y install ndisgtk ndiswrapper-utils-1.9 ndiswrapper-common
sudo dpkg -i ./package/google-chrome-beta_current_i386.deb
sudo apt-get -y install gnome-do shutter compizconfig-settings-manager gnome-splashscreen-manager

# Media Player
sudo apt-get -y install miro vlc

# Image Viewer
sudo apt-get -y install gthumb

# Screenlets
sudo apt-get -y install screenlets

# File Sharing
sudo apt-get -y install smbclient samba-common samba libpam-smbpass

# Putty
sudo apt-get -y install putty

# Wine
sudo apt-get -y install wine playonlinux

# Inkscape vector image editor
sudo apt-get -y install inkscape

# Kdenlive video editor
sudo apt-get -y install kdenlive

# Install Flash for Chrome
sudo apt-get -y install flashplugin-installer
sudo mkdir /opt/google/chrome/plugins
sudo cp /usr/lib/flashplugin-installer/libflashplayer.so /opt/google/chrome/plugins/

# virtualbox
# gdm-2.20
