#!/bin/bash

cd `dirname $0`
cd ..

sudo killall -s SIGQUIT kas_mineragent.exe
sleep 1
sudo ./bin/kas_mineragent.exe conf/config.json
