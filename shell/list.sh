#!/bin/bash

echo "list" | nc -q1 127.0.0.1  9001
echo "list" | nc -q1 127.0.0.1  9002 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9003 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9004 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9005 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9006 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9007 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  9008 | awk 'NR != 1'
