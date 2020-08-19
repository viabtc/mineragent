#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT bitcoin_mineragent.exe
sleep 1
./bin/bitcoin_mineragent.exe conf/config.json
