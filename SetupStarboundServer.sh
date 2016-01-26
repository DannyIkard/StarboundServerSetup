#!/bin/bash

#----------- Get steam username and password for SteamCMD login ----------
printf "\n\n%s" "Enter your steam login: "; read STEAMUSERNAME
printf "%s" "Enter your steam password: "; read -s STEAMPASSWORD

#----------- Install dependencies and directories ------------------------
sudo apt-get -y install lib32gcc1 libpng12-0
mkdir ~/steamcmd 2>/dev/null
cd ~/steamcmd

#-----------If steamcmd.sh doesn't exist, download it --------------------
if [ ! -f steamcmd.sh ]; then
  wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
  tar zxvf steamcmd_linux.tar.gz
  chmod +x steamcmd.sh
fi

#----------- Create server start/stop/restart script ---------------------
sudo bash -c "cat << EOF > /usr/local/bin/starboundserver
#!/bin/bash
case \"\\\$1\" in
start)
cd /home/k12/Steam/linux64
./starbound_server &
;;
stop)
killall -SIGINT starbound_server
;;
restart)
$0 stop
$0 start
;;
esac
exit 0
EOF"
sudo chmod +x /usr/local/bin/starboundserver

#----------- Create systemctl service ------------------------------------
sudo bash -c "cat << EOF > /lib/systemd/system/starboundserver.service
[Unit]
Description=Manage Starbound Server

[Service]
Type=forking
ExecStart=/usr/local/bin/starboundserver start
ExecStop=/usr/local/bin/starboundserver stop
ExecReload=/usr/local/bin/starboundserver restart
User=k12

[Install]
WantedBy=multi-user.target
EOF"

#----------- Enable systemctl service ------------------------------------
sudo systemctl daemon-reload
sudo systemctl enable starboundserver.service

#----------- Run SteamCMD to update or install ---------------------------
./steamcmd.sh +login $STEAMUSERNAME $STEAMPASSWORD +force_install_dir /home/k12/Steam +app_update 211820 +quit

exit 0