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
# DETECT FOLDER
if [ -d "/config" ]; then
	CONFIG_PATH="/config"
fi
# BAIKAL
if [ -d "/opt/scripta/etc" ]; then
	CONFIG_PATH="/opt/scripta/etc"
fi
# DAYUN
if [ -d "/var/www/html/resources" ]; then
	CONFIG_PATH="/var/www/html/resources"
fi
# INNOSILICON
if [ -d "/home/www/conf" ]; then
	CONFIG_PATH="/home/www/conf"
fi

cd $CONFIG_PATH
mkdir minerstat
chmod 777 minerstat
cd $CONFIG_PATH/minerstat

#############################
# DOWNLOAD
chmod 777 minerstat.sh
rm minerstat.sh
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
chmod 777 minerstat.sh

#############################
# SETTING UP USER

mount -o remount,rw  /

if [ $1 != "" ]; then
	if [ $2 != "" ]; then
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
rm runmeonboot
curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/runmeonboot
chmod 777 runmeonboot
#ln -s runmeonboot /etc/rc.d/

dir=$(pwd)
echo -n > /etc/init.d/minerstat
chmod 777 /etc/init.d/minerstat
echo "#!/bin/sh" >> /etc/init.d/minerstat
echo "sh $dir/runmeonboot" >> /etc/init.d/minerstat
chmod ugo+x /etc/init.d/minerstat

echo -n >  /etc/rcS.d/S71minerstat
echo "#!/bin/sh" >> /etc/rcS.d/S71minerstat
echo "sh $dir/runmeonboot" >> /etc/rcS.d/S71minerstat

update-rc.d minerstat defaults

#############################
# START THE SCRIPT

sleep 2
sh runmeonboot
nohup sync &
exit 0