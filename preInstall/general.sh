# ! /bin/sh


# Kernel Update
sudo ./joke-apt.sh install linux-headers-$(uname -r)

sudo ./joke-apt.sh install gnome-do compizconfig-settings-manager shutter

# Media Player
sudo ./joke-apt.sh install miro vlc

# Image Viewer
sudo ./joke-apt.sh install gthumb

# Screenlets
sudo ./joke-apt.sh install screenlets

# Putty
sudo ./joke-apt.sh install putty

# Wine
sudo ./joke-apt.sh install wine playonlinux

# Inkscape vector image editor
sudo ./joke-apt.sh install inkscape

# Kdenlive video editor
sudo ./joke-apt.sh install kdenlive


# Midi Editor
rosegarden

# Network Driver Interface Specification NDIS
# Utility for mapping windows driver
# Required to enable commercial download in Synaptic Manager > Settings

sudo ./joke-apt.sh install ndisgtk ndiswrapper-utils-1.9 ndiswrapper-common gnome-splashscreen-manager flashplugin-installer smbclient samba-common samba libpam-smbpass
