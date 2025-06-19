#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT ltc_mineragent.exe
sleep 1
./bin/ltc_mineragent.exe conf/config.json
