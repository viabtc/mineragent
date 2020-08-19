#!/bin/bash

echo "list" | nc -q1 127.0.0.1  8001
echo "list" | nc -q1 127.0.0.1  8002 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8003 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8004 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8005 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8006 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8007 | awk 'NR != 1'
echo "list" | nc -q1 127.0.0.1  8008 | awk 'NR != 1'
