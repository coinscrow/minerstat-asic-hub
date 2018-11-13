#/bin/bash

wget -O install.sh http://static.minerstat.farm/github/install.sh
chmod 777 *.sh
./install.sh $1 $2 $3 $4
