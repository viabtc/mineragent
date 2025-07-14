## Requirement 

Ubuntu server 22.04 x86_64 and above

## Install

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent/linux
```

start btc   
```
cd btc_mineragent
./shell/restart.sh
```

start ltc

```
cd ltc_mineragent
./shell/restart.h
```

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/btc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/ltc_mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.
