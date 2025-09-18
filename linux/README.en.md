# MinerAgent Deployment Guide for Linux (Ubuntu)

English | [简体中文](./README.md) | [Русский](./README.ru.md)

## System Requirements
- Operating System: Ubuntu Server 22.04 x86_64 or higher
- Processor: 4 cores or more
- Memory: 8 GB RAM or more
- Storage: 60 GB or more

## Deployment Steps
All steps below should be performed in the `Terminal` .

### 1. Configuration Environment 
Before deploying MinerAgent, you need to install the required dependencies by running the following commands:
```bash
sudo apt update
sudo apt install -y jq unzip wget
```

### 2. Download MinerAgent
If you want to install MinerAgent in a specific directory, use the `cd` command to navigate your desired location. This guide uses the default directory (`cd ~`) as the installation location.  
Run the following command to download MinerAgent:
```bash
wget https://download.viabtc.top/viabtc_mineragent.zip
unzip viabtc_mineragent.zip
```
After downloading, navigate to the following directory:  
```bash
cd mineragent-master/linux
```
### 3. Initial Startup of MinerAgent
For first-time deployment, you can use the `start.sh` script in the current directory to start the MinerAgent service in one step, and automatically set up cron to periodically monitor whether the agent service is running properly.  
**Basic Usage:**  
To start the agent for a specific coin (e.g., `BTC` or `LTC`):  
```bash
./start.sh btc
or
./start.sh ltc
```
**Advanced Usage (configurable mining pool server)**  
You can configure up to three mining pool server addresses.  
The format of mining pool server address: `host:port:[ssl|nossl]`  
- `host`: Mining pool server address (e.g., `btc.viabtc.com`)
- `port`: Mining pool server port (e.g., `3333`)
- `[ssl|nossl]`: Whether the mining pool server is SSL-encrypted

**Example:**  
To start the `BTC` agent and configure it with two pool server addresses:
```bash
./start.sh btc btc.viabtc.com:3333:nossl btc-ssl.viabtc.io:551:ssl
```
### 4. Connecting Miners
Miners should connect to the agent service using `IP:Port`.
IP is the `server IP` where the agent is running. The default ports for the BTC agent are `[3333 / 443 / 25]`. The default ports for the LTC agent are `[5555 / 446 / 26]`. You only need to use one of the listed ports.
How to check `server IP`:  
Run:
```bash
ip -a
```
You will see output similar to:
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
You should look for your network interface, which is usually `eth0` (wired connection) or `wlan0` (wireless connection).  
Within the details of these interfaces, find the line that begins with `inet`.  
`inet 192.168.1.100/24`  
Here, `192.168.1.100` is your `server IP` address.  
In the miner’s configuration page, set the BTC mining URL as: `stratum+tcp://192.168.1.100:3333`.

