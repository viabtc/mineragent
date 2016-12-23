#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT mineragent.exe
sleep 1
./bin/mineragent.exe conf/config.json
