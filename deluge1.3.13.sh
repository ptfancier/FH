#!/usr/bin/env bash
set -euo pipefail
#
# Copyright (c) 2017 Feral Hosting. This content may not be used elsewhere without explicit permission from Feral Hosting.
#
# This script can be used to install deluge and run initial configuration. It can also restart it and uninstall it.

# Functions

delugeMenu ()
{
    echo -e "\033[36m""deluge""\e[0m"
    echo "1 Install deluge"
    echo "2 Restart deluge"
    echo "3 Uninstall deluge"
    echo "q Quit the script"
}

binCheck () # checks for ~/bin
{
    if [[ ! -d ~/bin ]]
    then
        echo "Creating ~/bin first"
        mkdir -p ~/bin
    fi
}

cronAdd () # creates a temp cron to a variable, makes the necessary files. Each software to then check to see if job exists and add if not.
{
    tmpcron="$(mktemp)"
    mkdir -p ~/.cronjobs/logs
}

portGenerator () # generates a port to use with software installs
{
    portGen=$(shuf -i 10001-32001 -n 1)
}

portCheck () # runs a check to see if the port generated can be used
{
    while [[ "$(netstat -ln | grep ':'"$portGen"'' | grep -c 'LISTEN')" -eq "1" ]];
    do
        portGenerator;
    done
}

while [[ 1 ]]
do
    echo
    delugeMenu
    echo
    read -ep "Enter the number of the option you want: " CHOICE
    echo
    case "$CHOICE" in
        "1") # install qbittorent
            binCheck
            echo "Getting the necessary files and extracting them..." # need to get a lot of .debs for this...
            wget  http://raw.githubusercontent.com/ptfancier/FH/master/deluge1.3.13.tar.gz 
            echo "Already got it"
            tar -zxvf deluge1.3.13.tar.gz
            dpkg -x ~/deluge1.3.13/deluge-common_1.3.13+git20161130.48cedf63-3_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/deluged_1.3.13+git20161130.48cedf63-3_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/deluge-web_1.3.13+git20161130.48cedf63-3_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/libboost-python1.62.0_1.62.0+dfsg-4_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-attr_16.3.0-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-cffi-backend_1.9.1-2_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-click_6.6-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-colorama_0.3.7-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-constantly_15.1.0-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-cryptography_1.7.1-3_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-enum34_1.1.6-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-idna_2.2-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-incremental_16.10.1-3_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-ipaddress_1.0.17-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-libtorrent_1.1.1-1+b1_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-mako_1.0.6+ds1-2_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-markupsafe_0.23-3_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-openssl_16.2.0-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-pam_0.4.2-13.2_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-pyasn1_0.1.9-2_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-pyasn1-modules_0.0.7-0.1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-serial_3.2.1-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-service-identity_16.0.0-2_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-setuptools_33.1.1-1_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-twisted-bin_16.6.0-2_amd64.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-twisted-core_16.6.0-2_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-twisted-web_16.6.0-2_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-xdg_0.25-4_all.deb ~/deb-temp
            dpkg -x ~/deluge1.3.13/python-zope.interface_4.3.2-1_amd64.deb ~/deb-temp

            echo "Making the directories, configuring..."           
            mkdir -p ~/lib
            mkdir -p ~/share
            #mv -f ~/deb-temp/usr/share/pyshared/pyxdg-0.25.egg-info ~/deb-temp/usr/lib/python2.7/dist-packages
            mv ~/deb-temp/usr/lib/x86_64-linux-gnu/* ~/lib/
            mv ~/deb-temp/usr/lib/python2.7 ~/lib/
            mv ~/deb-temp/usr/share/* ~/share/
            mv ~/deb-temp/usr/bin/* ~/bin/
            rm -rf ~/deb-temp ~/deluge1.3.13
            mkdir -p ~/.config/deluge
            echo "{
  \"file\": 1, 
  \"format\": 1
}{
  \"hosts\": [
    [
      \"628690011fcdfecfcbe5464cd1e06c0e25ba508a\", 
      \"127.0.0.1\", 
      PORTNUM, 
      \"\", 
      \"\"
    ]
  ]
}" >~/.config/deluge/hostlist.conf.1.2
            
          
            portGenerator
            portCheck
            sed -i "s|PORTNUM|$portGen|g" ~/.config/deluge/hostlist.conf.1.2
            portGen1=$portGen
            while [[ "$portGen1" = "$portGen" ]]
            do
            	portGenerator
            	portCheck
            done
            echo "{
  \"file\": 1,
  \"format\": 1
}{
  \"port\": PORTNUM,
  \"enabled_plugins\": [],
  \"pwd_sha1\": \"2ce1a410bcdcc53064129b6d950f2e9fee4edc1e\",
  \"theme\": \"gray\",
  \"show_sidebar\": true,
  \"sidebar_show_zero\": false,
  \"pkey\": \"ssl/daemon.pkey\",
  \"https\": false,
  \"sessions\": {},
  \"base\": \"/\",
  \"pwd_salt\": \"c26ab3bbd8b137f99cd83c2c1c0963bcc1a35cad\",
  \"show_session_speed\": false,
  \"first_login\": false,
  \"cert\": \"ssl/daemon.cert\",
  \"session_timeout\": 3600,
  \"default_daemon\": \"\",
  \"sidebar_multiple_filters\": true
}" >~/.config/deluge/web.conf
 			sed -i "s|PORTNUM|$portGen|g" ~/.config/deluge/web.conf
            screen -dmS deluge /bin/bash -c 'export LD_LIBRARY_PATH=~/lib:/usr/lib;export PYTHONPATH=~/lib/python2.7/dist-packages/; export PATH=~/bin;   deluge-web '

            echo "$(/bin/bash -c 'export LD_LIBRARY_PATH=~/lib:/usr/lib;export PYTHONPATH=~/lib/python2.7/dist-packages/; export PATH=~/bin:$PATH; deluged -v') has been installed - access it on the URL below:"
            echo
            echo "http://$(whoami).$(hostname -f):$portGen"
            echo
            echo -e "The default password is" "\033[36m""deluge""\e[0m"
            echo
            echo "You should change these as soon as possible:"            
            ;;
            "q") # quit the script entirely
            exit
            ;;
        "2") # restart deluge
            if [[ ! -f ~/.config/deluge/hostlist.conf.1.2 ]]
            then
                echo "You don't have a config file for deluge - you need to (re)install it"
                break
            fi
            echo "Stopping any instances of deluge..."
            #pkill -fxu $(whoami) 'SCREEN -dmS qBittorrent /bin/bash -c export LD_LIBRARY_PATH=~/lib:/usr/lib; ~/bin/qbittorrent-nox' || true
            screen -S deluge -X quit
            sleep 3
             echo "Starting it back up..."
            screen -dmS deluge /bin/bash -c 'export LD_LIBRARY_PATH=~/lib:/usr/lib;export PYTHONPATH=~/lib/python2.7/dist-packages/; export PATH=~/bin;   deluge-web '
            sleep 3
            if pgrep -fu "$(whoami)" 'SCREEN -dmS deluge' > /dev/null 2>&1
            then
                echo "deluge has been restarted."
            else
                echo
                echo "Failing to start up deluge:"
                 /bin/bash -c 'export LD_LIBRARY_PATH=~/lib:/usr/lib;export PYTHONPATH=~/lib/python2.7/dist-packages/; export PATH=~/bin;   deluge-web '
            fi
            ;;
        "3") # uninstall
            echo -e "Uninstalling deluge will" "\033[31m""remove the deluge software, the associated torrents, their data and the software settings""\e[0m"

            ;;
        "q") # quit the script entirely
            exit
            ;;
    esac
done