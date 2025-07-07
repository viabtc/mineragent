#!/bin/bash

cd `dirname $0`
cd ..

sudo killall -s SIGQUIT btc_mineragent.exe
sleep 1
sudo ./bin/btc_mineragent.exe conf/config.json
