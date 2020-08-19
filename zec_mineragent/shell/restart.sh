#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT zec_mineragent.exe
sleep 1
./bin/zec_mineragent.exe conf/config.json
