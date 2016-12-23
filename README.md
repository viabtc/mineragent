## Requirement 

Ubuntu server 14.04 x86_64, 2G disk size.

## Install

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent && ./shell/restart.sh
```

Then run command: `crontab -e` add the flowing line:

```
*/1 * * * * $path/mineragent/shell/check_alive.sh >/dev/null 2>&1
```

The `$path` is the path where you install the mineragent.


## 系统要求

Ubuntu server 14.04 64 位系统，最小磁盘大小 2G.

## 安装

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent && ./shell/restart.sh
```

然后运行命令：`crontab -e` 添加下面这一行：

```
*/1 * * * * $path/mineragent/shell/check_alive.sh >/dev/null 2>&1
```

其中 `$path` 替换位 mineragent 安装的目录
