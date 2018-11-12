#!/bin/sh
echo "--------- MINERSTAT ASIC HUB (UNINSTALL) -----------"

echo "Uninstall => Start"

# kill running process
screen -S minerstat -X quit
screen -S ms-run -X quit # kill running process
echo "minerstat => Killed"


echo "Remove => Cronjobs"
# CGMINER CRON DELETE
if [ -d "/config" ]; then
    if [ -f "/config/cgminer.conf" ]; then
        if grep -q wipe "/config/network.conf"; then
            sed -i '$ d' /config/network.conf
        fi
        if grep -q minerstat "/config/network.conf"; then
            sed -i '$ d' /config/network.conf
        fi
    fi
fi
# BMMINER & SGMINER CRON DELETE
rm /etc/init.d/minerstat &> /dev/null

# MINERSTAT REMOVE
# ANTMINER
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


echo "Remove => /$CONFIG_PATH/minerstat/*"
rm -rf "/$CONFIG_PATH/minerstat"

echo "Uninstall => Done"

sleep 2
nohup sync > /dev/null 2>&1 &
exit 0
