#!/bin/bash

echo "list" | nc -q1 127.0.0.1  10001
echo "list" | nc -q1 127.0.0.1  10002 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10003 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10004 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10005 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10006 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10007 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  10008 | awk 'NR != 1'
