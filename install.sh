#!/bin/sh
echo "--------- MINERSTAT ASIC HUB (INSTALL) -----------"

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
# DOWNLOAD
chmod 777 minerstat.sh
rm minerstat.sh
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
chmod 777 minerstat.sh

#############################
# SETTING UP USER

if [ $1 != "" ]; then
	if [ $2 != "" ]; then
		echo -n > minerstat.txt
		echo "TOKEN=$1" > minerstat.txt
		echo "WORKER=$2" > minerstat.txt
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
rm runmeonboot.sh
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/runmeonboot
chmod 777 runmeonboot
ln -s runmeonboot /etc/rc.d/

#############################
# START THE SCRIPT
./runmeonboot