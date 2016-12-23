## Requirement 

Ubuntu server 14.04 x86_64, 2G disk size.

## Install

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent && ./shell/restart
```

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.
