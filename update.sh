#/bin/bash

cd /tmp 
wget -O install.sh http://static.minerstat.farm/github/install.sh
chmod 777 *.sh
sh install.sh $1 $2 $3 $4
