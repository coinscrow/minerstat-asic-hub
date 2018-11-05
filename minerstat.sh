#!/bin/sh

sleep 1

if ! screen -list | grep -q "ms-run"; then

    echo "--------- MINERSTAT ASIC HUB -----------"

    # Fake Process, Boot & Double instance protection
    screen -A -m -d -S ms-run sleep 365d

    sleep 10
    
    echo "-------- WAITING FOR CONNECTION -----------------"

    while ! ping minerstat.farm -w 1 | grep "0%"; do
        sleep 1
    done

    rm error.log &> /dev/null
    cat minerstat.txt 2> error.log

    #############################
    # GLOBAL VARIBLES

    TOKEN="null"
    WORKER="null"
    MODEL="null"

    ASIC="null"
    MINER="null"
    MAINT="0"

    # SYNC
    FOUND="null"
    TCMD="null"
    RESPONSE="null"
    POSTDATA="null"

    # CONFIG
    CONFIG_PATH="/tmp"
    CONFIG_FILE="null"
    SYNC_ROUND=0
    SYNC_MAX=45

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
                #echo "INFO => Detecting ASIC Type"
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

        # MINER
        if [ $TOKEN == "null" ]; then
            MODEL=$(sed -n 2p /usr/bin/compile_time)
            TOKEN=$(cat "$CONFIG_PATH/minerstat/minerstat.txt" | grep TOKEN= | sed 's/TOKEN=//g')
            WORKER=$(cat "$CONFIG_PATH/minerstat/minerstat.txt" | grep WORKER= | sed 's/WORKER=//g')
        fi

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
        #echo "Detected => $ASIC"
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
	LOCALIP=$(/sbin/ifconfig eth0 | grep Mask | sed 's/^.*addr/addr/' | cut -f1 -d" " | sed 's/[^0-9.]*//g')
        POSTDATA=$(curl -s --insecure --header "Content-type: application/x-www-form-urlencoded" --request POST --data "token=$TOKEN" --data "worker=$WORKER" --data "ip=$LOCALIP" --data "data=$RESPONSE" https://api.minerstat.com/v2/get_asic)
        remoteCMD
    }

    # 5) CHECK SERVER RESPOSNE FOR POSSIBLE PENDING REMOTE COMMANDS
    remoteCMD() {

        # AutoUpdate
        # 1 Round is 45sec, X + 45
        # 12 hour (60 x 60) x 12 = 43,200
	
	if [ "$MAINT" != "1" ]; then
		MAINT="1"
		maintenance
	fi
		
        SYNC_ROUND=$(($SYNC_ROUND + $SYNC_MAX))

        if [ "$SYNC_ROUND" -gt "3000" ]; then
            cd "$CONFIG_PATH"
            curl --insecure -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
            SYNC_ROUND=0
        fi

        # DEBUG
        #echo "API => Updated (Waiting for the next sync)"

        if [ $POSTDATA != "NULL" ]; then
            echo "Remote command => $POSTDATA"
        fi
        # echo $RESPONSE
	
	#READ=$(cat "/$CONFIG_PATH/$CONFIG_FILE")
		# Update config on the 3th sync
			if [ "$SYNC_ROUND" != "135" ]; then
				echo ""
			else 
				rm "$CONFIG_PATH/server.json"
				POSTIT=$(cd $CONFIG_PATH; wget -O server.json "http://static.minerstat.farm/asicproxy.php?token=$TOKEN&worker=$WORKER&type=$ASIC")
				if [ -s "$CONFIG_PATH/server.json" ]
	   			then 
   					#echo " file exists and is not empty "
					rm "/$CONFIG_PATH/$CONFIG_FILE"
					cp -f "/$CONFIG_PATH/server.json" "/$CONFIG_PATH/$CONFIG_FILE"
					chmod 777 "/$CONFIG_PATH/$CONFIG_FILE"
					echo "CONFIG UPDATED FROM SERVER SIDE"
					cat "/$CONFIG_PATH/$CONFIG_FILE"
			else
  				echo " file does not exist, or is empty "
			fi
			fi
				
        if [ $POSTDATA == "CONFIG" ]; then
            if [ $CONFIG_FILE != "null" ]; then
                cd $CONFIG_PATH #ENTER CONFIG DIRECTORY
                sleep 1 # REST A BIT
                #echo "NEW CONFIG => $NEWCONFIG";
                #if [ ! -z $NEWCONFIG ]; then
                echo "CONFIG => Updating $CONFIG_PATH/$CONFIG_FILE "
                rm "$CONFIG_PATH/$CONFIG_FILE"
                curl -f --silent -L --insecure "http://static.minerstat.farm/asicproxy.php?token=$TOKEN&worker=$WORKER&type=$ASIC" > "$CONFIG_PATH/$CONFIG_FILE"
                POSTDATA="REBOOT"
                sleep 6
                # DEBUG
                cat "$CONFIG_PATH/$CONFIG_FILE"
                #else
                #echo "CONFIG => Config request was blank."
                #fi
            fi
        fi
        if [ $POSTDATA == "RESTART" ]; then
            if [ $ASIC == "antminer" ]; then
                echo "RESTARTING MINER..."
                sleep 2
                /etc/init.d/cgminer.sh restart &> /dev/null
                /etc/init.d/bmminer.sh restart &> /dev/null
            else
                POSTDATA="REBOOT"
            fi
        fi
        if [ $POSTDATA == "REBOOT" ]; then
            sleep 3
            echo "REBOOTING MINER..."
            /sbin/shutdown -r now
        fi
        if [ $POSTDATA == "SHUTDOWN" ]; then
            sleep 2
            echo "SHUTTING DOWN..."
            /sbin/shutdown -h now
        fi
	
	clear
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
	   	
	    
            # IF THERES SOME API ISSUE THE ANTMINER WILL REBOOT OR RESTART ITSELF
            # NO FORCED REBOOT REQUIRED AFTER CONFIG EDIT.
            # BUT THESE CHANGES CAN'T BE SKIPPER OR UNLESS THE MACHINE BECOME UNSTABLE.

        fi
    }

    #############################
    # AUTO UPDATE
    # Replace the script during runtime, this not applies until a reboot

    aupdate() {
        curl --insecure -H 'Cache-Control: no-cache' -O -s https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/minerstat.sh
    }

    #############################
    # SYNC LOOP
    check
    #aupdate
    while true
    do
        sleep 45
        check
    done

else
    echo "ERROR => Minerstat is already running! See: screen -x minerstat"
fi
