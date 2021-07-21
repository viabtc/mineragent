#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT btc_mineragent.exe
sleep 1
./bin/btc_mineragent.exe conf/config.json
