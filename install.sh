#!/bin/sh
mount -o remount,rw  / #remount filesystem

echo "--------- MINERSTAT ASIC HUB (INSTALL) -----------"

if [ "$1" != "" ]; then
    if [ "$1" != "null" ]; then
        echo "TOKEN: ok"
    else
        echo "No ACCESS_KEY DEFINED"
        exit 0
    fi
else
    echo "No ACCESS_KEY DEFINED"
    exit 0
fi

if [ "$2" != "" ]; then
    if [ "$2" != "null" ]; then
        echo "WORKER: ok"
    else
        echo "No WORKER_NAME DEFINED"
        exit 0
    fi
else
    echo "No WORKER_NAME DEFINED"
    exit 0
fi

#############################
# TESTING CURL
echo "-*-*-*-*-*-*-*-*-*-*-*-*"
rm error.log &> /dev/null
curl 2> error.log

if grep -q libcurl.so.5 "error.log"; then
    echo "CURL PATCH APPLIED !"
    ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
else
    echo "CURL IS OK!"
fi


#############################
# TESTING CPU
cat /proc/cpuinfo


#############################
# TESTING NC
echo "-*-*-*-*-*-*-*-*-*-*-*-*"
rm error.log &> /dev/null
nc 2> error.log

if grep -q found "error.log"; then
    echo "NC PATCH APPLIED !"
    # INSTALL NC
    cd /bin
	curl -O https://busybox.net/downloads/binaries/1.21.1/busybox-armv7l # change this to GITHUB
	chmod 777 busybox-armv7l
	busybox-armv7l --install /bin
else
    echo "NC IS OK!"
fi


#############################
# DETECT-REMOVE INVALID CONFIGS
MINER="null"
TOKEN="null"
ASIC="null"

if [ -f "/etc/init.d/cgminer.sh" ]; then
    rm "/config/bmminer.conf" &> /dev/null
fi

if [ -f "/etc/init.d/bmminer.sh" ]; then
    rm "/config/cgminer.conf" &> /dev/null
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

if grep -q InnoMiner "/etc/issue"; then
	if [ -d "/config" ]; then
		if [ -f "/config/cgminer.conf" ]; then
			MINER="cgminer"
        	CONFIG_FILE="cgminer.conf"
        	ASIC="innosilicon"
			CONFIG_PATH="/config"
		fi
	fi
fi

cd $CONFIG_PATH

#############################
# REMOVE PREV. Installation
screen -S minerstat -X quit # kill running process
screen -S ms-run -X quit # kill running process
screen -wipe
rm -rf minerstat &> /dev/null
rm minerstat.sh &> /dev/null

mkdir minerstat &> /dev/null
chmod 777 minerstat &> /dev/null
cd $CONFIG_PATH/minerstat

MODEL=$(sed -n 2p /usr/bin/compile_time)

#############################
# DOWNLOAD
chmod 777 minerstat.sh &> /dev/null
rm minerstat.sh &> /dev/null
curl --insecure -H 'Cache-Control: no-cache' -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
chmod 777 minerstat.sh &> /dev/null

#############################
# SETTING UP USER

if [ $1 != "" ]; then
    if [ $2 != "" ]; then
        echo "---- USER -----"
        echo -n > minerstat.txt
        echo "TOKEN=$1" > minerstat.txt
        UPPER=$(echo "$2" | awk '{print toupper($0)}')
        echo "WORKER=$UPPER" >> minerstat.txt
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
curl --insecure -H 'Cache-Control: no-cache' -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/runmeonboot
curl --insecure -H 'Cache-Control: no-cache' -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/update.sh
chmod 777 runmeonboot &> /dev/null
#ln -s runmeonboot /etc/rc.d/

dir=$(pwd)

if [ -f "/config/network.conf" ]; then
    ## WIPE
    if grep -q wipe "/config/network.conf"; then
        echo "no wipe needed"
    else
        echo "screen -wipe; sleep 10" >> /config/network.conf
    fi
    ## CRON
    if grep -q minerstat "/config/network.conf"; then
        echo "cron installed"
    else
        echo "cron not installed, installing"
        echo "screen -A -m -d -S minerstat sh /config/minerstat/minerstat.sh" >> /config/network.conf
    fi	
else
	#if [ -f "/etc/profile" ]; then
	#	if grep -q minerstat "/etc/profile"; then
    #    	echo "cron installed"
    #	else
    #		echo "cron not installed, installing"
    #    	echo "screen -wipe; sleep 10" >> /etc/profile
    #    	echo "screen -A -m -d -S minerstat sh /config/minerstat/minerstat.sh" >> /etc/profile
    #	fi	
	#fi
fi

#echo -n > /etc/init.d/minerstat
#chmod 777 /etc/init.d/minerstat
#echo "#!/bin/sh" >> /etc/init.d/minerstat
#echo "sh $dir/runmeonboot" >> /etc/init.d/minerstat
#chmod ugo+x /etc/init.d/minerstat
#update-rc.d minerstat defaults

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

#if [ "$3" != "noupload" ]; then
    POSTREQUEST=$(curl -s --insecure -H 'Cache-Control: no-cache' --header "Content-type: application/x-www-form-urlencoded" --request POST --data "token=$TOKEN" --data "worker=$WORKER" --data "node=$CURRCONF" https://api.minerstat.com/v2/set_asic_config.php)
    echo "CONFIG POST => $POSTREQUEST"
#fi

echo "Installation => DONE"
echo "Notice => You can check the process running with: screen -list"

#############################
# START THE SCRIPT

if [ "$4" != "" ]; then
    echo "Extra: $4"
fi

sleep 2
screen -A -m -d -S minerstat ./minerstat.sh $4
screen -list

# DEBUG
echo "Extra: $4"

nohup sync > /dev/null 2>&1 &
exit 0
