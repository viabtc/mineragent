#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT bcc_mineragent.exe
sleep 1
./bin/bcc_mineragent.exe conf/config.json
