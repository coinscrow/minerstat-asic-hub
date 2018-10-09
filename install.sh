#!/bin/sh
echo "--------- MINERSTAT ASIC HUB (INSTALL) -----------"

#############################
# TESTING CURL
rm error.log &> /dev/null
curl 2> error.log

if grep -q libcurl.so.5 "error.log"; then
  echo "CURL PATCH APPLIED !"
  ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
  else
  echo "CURL IS OK!"
fi

#############################
# DETECT-REMOVE INVALID CONFIGS
MINER="null"
TOKEN="null"
ASIC="null"

if [ -f "/etc/init.d/cgminer.sh" ]; then
	rm "/config/bmminer.conf" &> /dev/null
fi

#############################
# DETECT FOLDER
if [ -d "/config" ]; then
	ASIC="antminer"
	CONFIG_PATH="/config"
	if [ -f "/config/cgminer.conf" ]; then
		MINER="cgminer"
		CONFIG_FILE="cgminer.conf"
	fi
	if [ -f "/config/bmminer.conf" ]; then
		MINER="bmminer"
		CONFIG_FILE="bmminer.conf"
	fi
	## CRON
	if grep -q minerstat "/config/network.conf"; then
		echo "cron installed"
	else
		echo "cron not installed"
		echo "screen -A -m -d -S minerstat sh /config/minerstat/minerstat.sh" >> /config/network.conf
	fi
fi
	
if [ -d "/opt/scripta/etc" ]; then
	CONFIG_FILE="miner.conf"
	MINER="sgminer"
	CONFIG_PATH="/opt/scripta/etc"
	ASIC="baikal"
fi

if [ -f "/config/bmminer.conf" ]; then
	MINER="bmminer"
	CONFIG_FILE="bmminer.conf"
fi

if [ -d "/var/www/html/resources" ]; then
	MINER="cgminer"
	CONFIG_FILE="cgminer.config"
	CONFIG_PATH="/var/www/html/resources"
	ASIC="dayun"
fi

if [ -d "/home/www/conf" ]; then
	MINER="cgminer"
	CONFIG_FILE="cgminer.conf"
	CONFIG_PATH="/home/www/conf"
	ASIC="innosilicon"
fi

cd $CONFIG_PATH

#############################
# REMOVE PREV. Installation
screen -S minerstat -X quit # kill running process
rm -rf minerstat &> /dev/null
rm minerstat.sh &> /dev/null

mkdir minerstat &> /dev/null
chmod 777 minerstat &> /dev/null
cd $CONFIG_PATH/minerstat

MODEL=$(sed -n 2p /usr/bin/compile_time)

mount -o remount,rw  / #remount filesystem

#############################
# DOWNLOAD
chmod 777 minerstat.sh &> /dev/null
rm minerstat.sh &> /dev/null
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
chmod 777 minerstat.sh &> /dev/null

#############################
# SETTING UP USER

if [ $1 != "" ]; then
	if [ $2 != "" ]; then
		echo "---- USER -----"
		echo -n > minerstat.txt
		echo "TOKEN=$1" > minerstat.txt
		echo "WORKER=$2" >> minerstat.txt
		cat minerstat.txt # Echo after finish
		else
		echo "EXIT => Worker is not defined"
		exit 0
	fi
	else
	echo "EXIT => Token is not defined"
	exit 0
fi

#############################
# SETTING UP CRON
rm runmeonboot &> /dev/null
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/runmeonboot
chmod 777 runmeonboot &> /dev/null
#ln -s runmeonboot /etc/rc.d/

dir=$(pwd)

if [ $ASIC != "antminer" ]; then
	echo -n > /etc/init.d/minerstat
	chmod 777 /etc/init.d/minerstat
	echo "#!/bin/sh" >> /etc/init.d/minerstat
	echo "sh $dir/runmeonboot" >> /etc/init.d/minerstat
	chmod ugo+x /etc/init.d/minerstat
	update-rc.d minerstat defaults
fi

#if [ $MINER != "cgminer" ]; then
#	echo -n >  /etc/rcS.d/S71minerstat
#	echo "#!/bin/sh" >> /etc/rcS.d/S71minerstat
#	echo "sh $dir/runmeonboot" >> /etc/rcS.d/S71minerstat
#fi

########################
# POST Config
TOKEN=$1
WORKER=$2
CURRCONF=$(cat "$CONFIG_PATH/$CONFIG_FILE")

echo "$CURRCONF"
	
#if [ $CURRCONF != "" ]; then
	POSTREQUEST=$(curl -s --insecure --header "Content-type: application/x-www-form-urlencoded" --request POST --data "token=$TOKEN" --data "worker=$WORKER" --data "node=$CURRCONF" https://api.minerstat.com/v2/set_asic_config.php)
	echo "CONFIG POST => $POSTREQUEST"
#fi		

echo "Installation => DONE"
echo "Notice => You can check the process running with: screen -list"

#############################
# START THE SCRIPT

sleep 2
sh runmeonboot
nohup sync > /dev/null 2>&1 &
exit 0