#!/bin/bash

cd `dirname $0`
cd ..

sudo killall -s SIGQUIT ltc_mineragent.exe
sleep 1
sudo ./bin/ltc_mineragent.exe conf/config.json
