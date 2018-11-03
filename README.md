![minerstat logo](https://cdn.rawgit.com/minerstat/minerstat-asic/master/docs/logo_full.svg)

# minerstat ASIC Hub

## What is this?
Monitoring and management client installed on the ASIC. The software makes possible to monitor your ASICs without any external monitoring software.
If you are running a larger management we recommend to check our ASIC Node.

**Supported and tested ASICs:**
* Antminer A3
* Antminer B3
* Antminer D3 / D3 Blissz
* Antminer E3
* Antminer L3+ / L3++
* Antminer S1-S9, S9i, S9j (All firmware)
* Antminer T9 / T9+
* Antminer X3
* Antminer Z9 / Z9-Mini

Work in progress for more ASIC support.

## Installation & Update

Login with SSH to your asic and execute the following command:
``` sh
cd /tmp && wget -O install.sh http://static.minerstat.farm/github/install.sh && chmod 777 *.sh && sh install.sh ACCESS_KEY WORKER
```

Make sure you replace **ACCESS_KEY** / **WORKER** to your details in the end of the above command. [Case sensitive!]

Default SSH Login

| ASIC          | Username  | Password        |
| ------------- |:---------:| ---------------:|
| Antminer      | root      | admin           |


## Bulk Installation from Linux Computer [ or from msOS]
``` sh
cd /tmp && wget -O bulk.sh https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/bulk-install.sh && chmod 777 *.sh && sh bulk.sh
```

First you need to import and/or add manually your workers to the website.
The bulk install script will ask your **ACCESS_KEY** and **GROUP/LOCATION** only. The rest of process is automatic.

## How the software works?

<img src="https://raw.githubusercontent.com/minerstat/minerstat-asic-hub/master/docs/works-asic-hub.svg?sanitize=true" width="65%">


## Uninstall
``` sh
cd /tmp && wget -O uninstall.sh http://static.minerstat.farm/github/uninstall.sh && chmod 777 *.sh && sh uninstall.sh
```

## 

***© minerstat OÜ*** in 2018


***Contact:*** app [ @ ] minerstat.com 


***Mail:*** Sepapaja tn 6, Lasnamäe district, Tallinn city, Harju county, 15551, Estonia

## 
