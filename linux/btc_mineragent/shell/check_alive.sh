#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

cd `dirname $0`
cd ..

proc_num=`ps -ef | grep btc_mineragent_ | grep -v grep | wc -l`
if [ $proc_num -eq 0 ]
then
    ./shell/restart.sh
else
    # check zombie process
    zombie_num=`ps aux | grep '[b]tc_mineragent_' | awk '$8=="Z"' | wc -l`
    if [ $zombie_num -gt 0 ]
    then
        ./shell/restart.sh
    else
        echo "btc_mineragent is running"
    fi
fi
