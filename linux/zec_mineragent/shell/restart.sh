#!/bin/bash

cd `dirname $0`
cd ..

sudo killall -s SIGQUIT zec_mineragent.exe
sleep 1
sudo ./bin/zec_mineragent.exe conf/config.json
