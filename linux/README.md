# Linux(Ubuntu系统)版本代理服务器部署

简体中文 | [English](./README.en.md) | [Русский](./README.ru.md)

## 配置要求
- 操作系统：Ubuntu server 22.04 x86_64 或以上
- 处理器：4核 或以上
- 内存：8G RAM 或以上
- 存储空间：60GB 或以上

## 部署步骤
以下步骤需要在 `Terminal`  终端下执行命令完成。

### 1. 配置环境 
在部署MinerAgent之前，需要安装相应的依赖库，执行以下命令：
```bash
sudo apt update
sudo apt install git
sudo apt install jq
```

### 2. 下载 MinerAgent
如果你对MinerAgent安装位置有要求，可自行通过 `cd`  命令进入相应目录下载，此文档以默认目录（ `cd ~`  ）为安装目录。  
执行下载命令：
```bash
git clone https://github.com/viabtc/mineragent.git
```
下载完成后，进入目录：  
```bash
cd mineragent/linux
```
### 3. 初次启动MinerAgent代理服务
初次部署可以使用当前目录下的 `start.sh`  脚本一键执行启动MinerAgent代理服务，并自动设置cron定时监控代理服务是否正常运行。  
**基本用法：**  
要启动特定币种的代理（例如 `btc`  或者 `ltc` ）：  
```bash
sudo ./start.sh btc
或
sudo ./start.sh ltc
```
**高级用法（可配置矿池服务器）：**  
最多可以配置3个矿池服务器地址。  
矿池服务器地址的格式为 `host:port:[ssl|nossl]`：  
- `host` : 矿池服务器地址（例如：`btc.viabtc.com`）  
- `port` : 矿池服务器端口（例如：`3333`）  
- `[ssl|nossl]` : 该矿池服务器是ssl地址或者是非ssl地址  

**例：**  
要启动 `BTC` 代理并使用两个矿池服务器地址对其进行配置：
```bash
sudo ./start.sh btc btc.viabtc.com:3333:nossl btc-ssl.viabtc.io:551:ssl
```
### 4. 矿机连接
矿机需要通过 `IP:端口` 连接代理服务。
其中，IP为代理服务所在的 `服务器IP` ，BTC代理服务器默认的端口为 `[3333/443/25]` ，LTC代理服务器默认的端口为 `[5555/446/26]` ，端口只需要任选其一就好。  
查看 `服务器IP` 的方法：  
执行命令：
```bash
ip -a
```
执行后，你会看到类似下面的输出：
```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:0e:63:9b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic noprefixroute eth0
       valid_lft 86311sec preferred_lft 86311sec
```
你需要关注的是你的网络接口，通常是 `eth0` (有线连接) 或 `wlan0` (无线连接)。在这些接口的详细信息中，找到以 `inet` 开头的那一行。  
`inet 192.168.1.100/24`  
这里的 `192.168.1.100` 就是你的 `服务器 IP`  地址。  
在矿机配置界面，BTC配置挖矿地址： `stratum+tcp://192.168.1.100:3333` 。
