## Requirement 

Ubuntu server 14.04 x86_64, 2G disk size.

## Install

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent
```

start btc   
```
cd btc_mineragent
./shell/restart.sh
```

start bcc

```
cd bcc_mineragent
./shell/restart.h
```

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/btc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bcc_mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.
