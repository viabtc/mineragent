#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT dash_mineragent.exe
sleep 1
./bin/dash_mineragent.exe conf/config.json
