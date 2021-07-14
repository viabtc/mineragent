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

start bsv

```
cd bsv_mineragent
./shell/restart.h
```

start bitcoin

```
cd bitcoin_mineragent
./shell/restart.h
```

start ltc

```
cd ltc_mineragent
./shell/restart.h
```

start zec

```
cd zec_mineragent
./shell/restart.h
```

start dash

```
cd dash_mineragent
./shell/restart.h
```

start eth

```
cd eth_mineragent
./shell/restart.h
```

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/btc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bcc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/ltc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/zec_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/dash_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bitcoin_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bsv_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/eth_mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.
