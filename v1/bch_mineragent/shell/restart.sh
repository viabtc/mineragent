#!/bin/bash

cd `dirname $0`
cd ..

killall -s SIGQUIT bch_mineragent.exe
sleep 1
./bin/bch_mineragent.exe conf/config.json
