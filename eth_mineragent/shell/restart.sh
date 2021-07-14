#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT eth_mineragent.exe
sleep 1
./bin/eth_mineragent.exe conf/config.json
