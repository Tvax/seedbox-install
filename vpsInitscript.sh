#!/bin/sh

##Check if distribution is supported
if [[ -z "$(uname -a | grep Ubuntu)" && -z "$(uname -a | grep Debian)" ]];
then
        echo Distro not supported
        exit 1
fi

##Updates && Upgrades
sudo apt-get update;
sudo apt-get upgrade;
sudo apt-get install curl;

##Deluge
sudo apt-get install deluge;
sudo apt-get install deluge-web;
sudo apt-get install deluged;
sudo apt-get install deluge-console;

sudo echo "[Unit]
Description=Deluge Bittorrent Client Web Interface
Documentation=man:deluge-web
After=network-online.target deluged.service
Wants=deluged.service
[Service]
Type=simple
User=root
Group=root
UMask=027
ExecStart=/usr/bin/deluge-web
Restart=on-failure
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/deluge-web.service;
sudo systemctl enable /etc/systemd/system/deluge-web.service;
sudo systemctl start deluge-web;

sudo echo "[Unit]
Description=Deluge Bittorrent Client Daemon
Documentation=man:deluged
After=network-online.target
[Service]
Type=simple
User=root
Group=root
UMask=007
ExecStart=/usr/bin/deluged -d
Restart=on-failure
# Time to wait before forcefully stopped.
TimeoutStopSec=300
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/deluged.service;
sudo systemctl enable /etc/systemd/system/deluged.service;
sudo systemctl start deluged;

##PlexMediaServer
cd;
sudo bash -c "$(wget -qO - https://raw.githubusercontent.com/mrworf/plexupdate/master/extras/installer.sh)";
sudo service plexservermedia start;

##Sonarr
sudo apt-get install libmono-cil-dev;
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC;
sudo echo "deb http://apt.sonarr.tv/ master main" | sudo tee /etc/apt/sources.list.d/sonarr.list;
sudo apt-get update;
sudo apt-get install nzbdrone;

sudo echo "[Unit]
Description=Sonarr Daemon

[Service]
User=root
Group=root

Type=simple
PermissionsStartOnly=true
ExecStart=/usr/bin/mono /opt/NzbDrone/NzbDrone.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/sonarr.service;
systemctl enable sonarr.service;
sudo service sonarr start;

##Radarr
sudo apt update && apt install libmono-cil-dev curl mediainfo;
sudo apt-get install mono-devel mediainfo sqlite3 libmono-cil-dev -y;
cd /tmp;
wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.45/Radarr.develop.0.2.0.45.linux.tar.gz;
sudo tar -xf Radarr* -C /opt/;
sudo chown -R root:root /opt/Radarr;

sudo echo "[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/bin/mono /opt/Radarr/Radarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/radarr.service;
sudo systemctl enable radarr;
sudo service radarr start;

##Jackett
sudo apt-get install libcurl4-openssl-dev;
wget https://github.com/Jackett/Jackett/releases/download/v0.7.1622/Jackett.Binaries.Mono.tar.gz;
sudo tar -xf Jackett* -C /opt/;
sudo chown -R root:root /opt/Jackett;

sudo echo "[Unit]
Description=Jackett Daemon
After=network.target

[Service]
WorkingDirectory=/opt/Jackett/
User=root
ExecStart=/usr/bin/mono --debug JackettConsole.exe --NoRestart
Restart=always
RestartSec=2
Type=simple
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/jackett.service;
sudo systemctl enable jackett;
sudo service jackett start;

##Headphones
sudo apt-get install git-core python;
cd /opt;
git clone https://github.com/rembo10/headphones.git;
sudo touch /etc/default/headphones;
sudo chmod +x /opt/headphones/init-scripts/init.ubuntu;
sudo ln -s /opt/headphones/init-scripts/init.ubuntu /etc/init.d/headphones;
sudo update-rc.d headphones defaults;
sudo update-rc.d headphones enable;
sudo service headphones start;