![minerstat logo](https://cdn.rawgit.com/minerstat/minerstat-asic/master/docs/logo_full.svg)

# minerstat ASIC Hub

## What is this?
Monitoring and management client installed on the ASIC. The software makes possible to monitor your ASICs without any external monitoring software.
If you are running a larger management we recommend to check our ASIC Node.

**NOTE: The software is in its Alpha, however, it is unable to harm your system.**

Supported ASICs:

The supported list will be announced in Beta.

## Installation

Login with SSH to your asic and execute the following command:
``` sh
cd /tmp && wget -O install.sh http://static.minerstat.farm/github/install.sh && chmod 777 *.sh && sh install.sh TOKEN WORKER
```

Make sure you replace **TOKEN** / **WORKER** to your details in the end of the above command.

Default SSH Login

| ASIC          | Username  | Password        |
| ------------- |:---------:| ---------------:|
| Antminer      | root      | admin           |
| Baikal        | admin     | root            |
| Dayun         | root      | envision        |
| Innosilicon   | root      | innot1t2        |
| Innosilicon   | root      | t1t2t3a5        |
| Innosilicon   | root      | blacksheepwall  |

## How it works?

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
