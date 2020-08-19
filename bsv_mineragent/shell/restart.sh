#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT bsv_mineragent.exe
sleep 1
./bin/bsv_mineragent.exe conf/config.json
