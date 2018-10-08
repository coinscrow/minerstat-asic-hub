#!/bin/sh
echo "--------- MINERSTAT ASIC HUB -----------"

rm error.log
cat minerstat.txt 2> error.log

#############################
# VALIDATE INSTALLATION

if grep -q such "error.log"; then
	echo "ERROR => Please reinstall the software."
	echo "EXIT => CODE (1)"
	exit 1
fi

#############################
# GLOBAL VARIBLES

# MINER
TOKEN=$(cat minerstat.txt | grep 'TOKEN="' | sed 's/TOKEN="//g' | sed 's/"//g')
WORKER=$(cat minerstat.txt | grep 'WORKER="' | sed 's/WORKER="//g' | sed 's/"//g')

ASIC="null"
MINER="null"

# SYNC
FOUND="null"
TCMD="null"
RESPONSE="null"
POSTDATA="null"

# CONFIG
CONFIG_PATH="/tmp"
CONFIG_FILE="null"

#############################
# TESTING CURL
rm error.log
curl 2> error.log

if grep -q libcurl.so.5 "error.log"; then
  echo "CURL PATCH APPLIED !"
  ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
  else
  echo "CURL IS OK!"
fi

#############################
# CORE FUNCTIONS

# 1) ASSIGN JOBS FOR DIFFERENT ASIC TYPES
check() {
# RESET TO NULL/TIMEOUT ON EVERY SYNC
RESPONSE="timeout"
POSTDATA="null"
case $ASIC in
	antminer)
		fetch
		;;
	baikal)
		fetch
		break
		;;
	dayun)
		fetch
		break
		;;
	innosilicon)
		fetch
		break
		;;
	null)
		echo "INFO => Detecting ASIC Type"
		detect
		;;
	err)
		echo "EXIT => CODE (0)"
		exit 0
		;;
  esac
}

# 2 DETECT ASIC TYPE
detect() {
	# POSSIBLE NEED NEW METHOD OR MORE ADVANCED Detecting
	# TEMPORARY WILL BE GOOD
	
	# ANTMINER
	if [ -d "/config" ]; then
		ASIC="antminer"
		CONFIG_PATH="/config"
		if [ -f "/config/cgminer.conf" ]; then
			MINER="cgminer"
		fi
		if [ -f "/config/bmminer.conf" ]; then
			MINER="bmminer"
		fi
		FOUND="Y"
		check
	fi
	# BAIKAL
	if [ -d "/opt/scripta/etc" ]; then
		ASIC="baikal"
		MINER="sgminer"
		CONFIG_PATH="/opt/scripta/etc"
		FOUND="Y"
		check
	fi
	# DAYUN
	if [ -d "/var/www/html/resources" ]; then
		ASIC="dayun"
		MINER="sgminer"
		CONFIG_PATH="/var/www/html/resources"
		FOUND="Y"
		check
	fi
	# INNOSILICON
	if [ -d "/home/www/conf" ]; then
		ASIC="innosilicon"
		MINER="cgminer"
		CONFIG_PATH="/home/www/conf"
		FOUND="Y"
		check
	fi
	# DRAGONMINT
	# NOT SURE ?
	
	if [ $FOUND == "null" ]; then
		FOUND="err"
		echo "ERROR => This machine is not supported."
		echo "ERROR => Try to use ASIC Node instead."
		echo "EXIT => CODE (0)"
		exit 0
	fi
	
}

# 3) DETECT IS OK, GET DATA FROM TCP
fetch() {
	echo "$ASIC detected !"
	if [ $ASIC != "baikal" ]; then
		QUERY=$(echo '{"command": "stats+summary+pools"}' | nc 127.0.0.1 4028)
		RESPONSE=$QUERY
		post
	else
		exec 3<>/dev/tcp/127.0.0.1/4028
		echo '{"command": "stats+summary+pools+devs"}' 1>&3
		QUERY=$(cat <&3)
		RESPONSE=$QUERY
		post
	fi
}

# 4) SEND DATA TO THE SERVER
post() {
	#echo "{\"token\":\"$TOKEN\",\"worker\":\"$WORKER\",\"data\":\"$RESPONSE\"}"
	POSTDATA=$(curl -s --insecure --header "Content-type: application/x-www-form-urlencoded" --request POST --data "token=$TOKEN" --data "worker=$WORKER" --data "data=$RESPONSE" https://api.minerstat.com/v2/get_asic)
	remoteCMD
}

# 5) CHECK SERVER RESPOSNE FOR POSSIBLE PENDING REMOTE COMMANDS
remoteCMD() {

	# DEBUG
	# echo "$POSTDATA"
	# echo $RESPONSE

	if [ $POSTDATA == "CONFIG" ]; then
		if [ $CONFIG_FILE != "null" ]; then
			cd $CONFIG_PATH #ENTER CONFIG DIRECTORY
			sleep 1 # REST A BIT
			rm $FILE # REMOVE CONFIG
			wget -O $FILE "http://static.minerstat.farm/asicproxy.php?token=$TOKEN&worker=$WORKER&type=$ASIC"
			POSTDATA="RESTART"
		fi
	fi
	if [ $POSTDATA == "RESTART" ]; then
		if [ $ASIC == "antminer"]; then
			/etc/init.d/cgminer.sh restart > /dev/null 
			/etc/init.d/bmminer.sh restart > /dev/null
		else
			POSTDATA="REBOOT"
		fi
	fi
	if [ $POSTDATA == "REBOOT" ]; then
		/sbin/shutdown -r
	fi
	if [ $POSTDATA == "SHUTDOWN" ]; then
		/sbin/shutdown
	fi
}

#############################
# MAINTAIN 
# NOTICE: THIS iS ONLY RUN ON ASIC BOOT OR SOFTWARE START

maintenance() {
	# ANTMINER
	if [ -d "/config" ]; then
		if [ -f "/config/cgminer.conf" ]; then
			CONFIG_FILE="cgminer.conf"
			CONFIG_PATH="/config"
		fi
		if [ -f "/config/bmminer.conf" ]; then
			CONFIG_FILE="bmminer.conf"
			CONFIG_PATH="/config"
		fi
		
		# SET CONFIG FILE WRITEABLE
		chmod 777 "/$CONFIG_PATH/$CONFIG_FILE"
		
		# REMOVE ALL API PARAMETERS
		cat "/$CONFIG_PATH/$CONFIG_FILE" | sed '/api-listen/d' >> "/$CONFIG_PATH/$CONFIG_FILE"
		cat "/$CONFIG_PATH/$CONFIG_FILE" | sed '/api-network/d' >> "/$CONFIG_PATH/$CONFIG_FILE"
		cat "/$CONFIG_PATH/$CONFIG_FILE" | sed '/api-groups/d' >> "/$CONFIG_PATH/$CONFIG_FILE"
		cat "/$CONFIG_PATH/$CONFIG_FILE" | sed '/api-allow/d' >> "/$CONFIG_PATH/$CONFIG_FILE"
		
		# APPLY NEW ONES
		sed -i "\$i \"api-listen\": true," "/$CONFIG_PATH/$CONFIG_FILE"
		sed -i "\$i \"api-network\": true," "/$CONFIG_PATH/$CONFIG_FILE"
		sed -i "\$i \"api-groups\": \"A:stats:pools:devs:summary:version\"," "/$CONFIG_PATH/$CONFIG_FILE"
		sed -i "\$i \"api-allow\": \"A:127.0.0.1,W:127.0.0.1\"" "/$CONFIG_PATH/$CONFIG_FILE"
		
		# IF THERES SOME API ISSUE THE ANTMINER WILL REBOOT OR RESTART ITSELF
		# NO FORCED REBOOT REQUIRED AFTER CONFIG EDIT.
		# BUT THESE CHANGES CAN'T BE SKIPPER OR UNLESS THE MACHINE BECOME UNSTABLE.
			
	fi
	check
}

#############################
# SYNC LOOP
maintenance
while true
do 
	sleep 45
	check
done