## Requirement 

Ubuntu server 20.04 x86_64, 10G disk size.

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

start bch

```
cd bch_mineragent
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

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/btc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bch_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/ltc_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/zec_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/dash_mineragent/shell/check_alive.sh >/dev/null 2>&1
*/1 * * * * $path/bitcoin_mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.
