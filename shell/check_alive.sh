#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

cd `dirname $0`
cd ..

proc_num=`ps -ef | grep poolbench.exe | grep -v grep | wc -l`
if [ $proc_num -eq 0 ]
then
    ./shell/restart.sh
fi
