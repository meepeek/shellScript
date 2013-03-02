#!/bin/bash

#Check if there are at least one parameter
if [ $# -lt 1 ]
then
   echo "Incorrect format. Please, see './install_kiba-dock-en.sh ?' for more information"
   exit 1
fi

#Check if first parameter is '?'
if [ $1 = "?" ]
then
   echo "This script runs in this mode:"
   echo "sudo ./install_kiba-dock-en.sh [i|u|?] [options]"
   echo ""
   echo "[i|u|?]:"
   echo "   i -> Install Kiba-dock (don't affect [options])"
   echo "   u -> Upgrade Kiba-dock"
   echo "   ? -> Show this help (don't affect [options])"
   echo ""
   echo "[options]:"
   echo "   If you wnat upgrade [u], you must put a string"
   echo "   with the modules that you want to compile."
   echo "   List of them:"
   echo "      a -> akamaru"
   echo "      k -> kiba-dock"
   echo "      p -> kiba-plugins"
   echo "      d -> kiba-dbus-plugins"
   echo "      g -> gaim"
   echo "   NOTE: It will be installed as same order as appears."
   echo "   For example: akp"
   echo "   Will install in this order:"
   echo "      - Akamaru"
   echo "      - Kiba-dock"
   echo "      - Kiba-plugins"
   exit 2
fi

#Check if user want to install
if [ $1 = "i" ]
then
   echo ""
   echo ""
   echo "Installing necessary files ..."
   echo ""
   echo ""

   sudo apt-get install fakeroot automake1.9 build-essential libpango1.0-dev libgtk2.0-dev libgconf2-dev  libglitz-glx1-dev librsvg2-dev libglade2-dev libxcomposite-dev subversion libtool libgtop2-dev python-gtk2-dev libgnome-menu-dev libgnomeui-dev libgnomevfs2-dev intltool libxml2-dev libglitz1-dev libcairo2 libdbus-1-dev libgtop2-7 libgnomevfs2-0 libgnomeui-0 librsvg2-2 python-feedparser libasound2-dev libsdl1.2-dev libdbus-glib-1-dev libgstreamer-plugins-base0.10-dev libgstreamer0.10-dev libgstreamer0.10-0

   echo ""
   echo ""
   echo "Downloading Kiba-dock from svn ..."
   echo ""
   echo ""

   svn co https://kibadock.svn.sourceforge.net/svnroot/kibadock/trunk/ kiba

   echo ""
   echo ""
   echo "Enter to kiba/"

   cd kiba

   echo "Enter to kiba/akamaru/"

   cd akamaru

   echo ""
   echo ""
   echo "Compiling  akamaru ..."
   echo ""
   echo ""

   ./autogen.sh  --prefix="/usr"
   make
   sudo make install

   echo ""
   echo ""
   echo "Exit to kiba/"
   echo "Enter to kiba/kiba-dock/"

   cd ..
   cd kiba-dock

   echo ""
   echo ""
   echo "Compiling kiba-dock ..."
   echo ""
   echo ""

   ./autogen.sh  --enable-akamaru
   make
   sudo make install

   echo ""
   echo ""
   echo "Exit to kiba/"
   echo "Enter to kiba/kiba-plugins/"

   cd ..
   cd kiba-plugins

   echo ""
   echo ""
   echo "Compiling kiba-plugins ..."
   echo ""
   echo ""

   ./autogen.sh  --enable-gst
   make
   sudo make install

   echo ""
   echo ""
   echo "Exit to kiba/"
   echo "Enter to kiba/kiba-dbus-plugins/"

   cd ..
   cd kiba-dbus-plugins

   echo ""
   echo ""
   echo "Compiling kiba-dbus-plugins ..."
   echo ""
   echo ""

   ./autogen.sh
   make
   sudo make install

   echo ""
   echo ""
   echo "Exit to kiba/"

   cd ..

   #Ask for gaim
   echo ""
   echo ""
   echo "Do you want to install gaim plugin (y/n)?"
   read gaim

   #Check if user want to install it
   if [ $gaim = "s" ]
   then
      echo ""
      echo ""
      echo "Enter to kiba/kiba-gaim-plugin/"

      cd kiba-gaim-plugin

      echo ""
      echo ""
      echo "Compiling kiba-gaim-plugin ..."
      echo ""
      echo ""

      ./autogen.sh
      make
      sudo make install

      echo ""
      echo ""
      echo "Exit to kiba/"

      cd ..
   fi

   echo ""
   echo ""
   echo "Exit to /"
   echo ""
   echo ""
   echo "Kiba-dock is installed now!"
   echo "To run Kiba-dock, you must execute 'kiba-dock'"
   echo ""
   echo ""
   exit 3
fi

#Check if user want to upgrade kiba-dock
if [ $1 = "u" ]
then
   #Upgrade the program
   echo ""
   echo ""
   echo "Upgrading kiba-dock ..."
   echo ""
   echo ""
   svn up

   cd kiba

   #Analizing [options] parameter
   i=1

   while [ $( echo $2 | cut -c$i ) != "" ] 2> kd_exit
   do
      tmp=$( echo $2 | cut -c$i )

      if [ $tmp = "a" ]
      then
         echo ""
         echo ""
         echo "Compiling akamaru ..."
         echo ""
         echo ""

         cd akamaru
         ./autogen.sh  --prefix="/usr"
         make
         sudo make install
         cd ..
      fi

      if [ $tmp = "k" ]
      then
         echo ""
         echo ""
         echo "Compiling kiba-dock ..."
         echo ""
         echo ""

         cd kiba-dock
         ./autogen.sh  --enable-akamaru
         make
         sudo make install
         cd ..
      fi

      if [ $tmp = "p" ]
      then
         echo ""
         echo ""
         echo "Compiling kiba-plugins ..."
         echo ""
         echo ""

         cd kiba-plugins
         ./autogen.sh  --enable-gst
         make
         sudo make install
         cd ..
      fi

      if [ $tmp = "d" ]
      then
         echo ""
         echo ""
         echo "Compiling kiba-dbus-plugins ..."
         echo ""
         echo ""

         cd kiba-dbus-plugins
         ./autogen.sh
         make
         sudo make install
         cd ..
      fi

      if [ $tmp = "g" ]
      then
         echo ""
         echo ""
         echo "Compiling kiba-gaim-plugin ..."
         echo ""
         echo ""

         cd kiba-gaim-plugin
         ./autogen.sh
         make
         sudo make install
         cd ..
      fi

      #Incrementamos la i en 1
      let i=i+1

   done

   rm kd_exit
   exit 5
fi
