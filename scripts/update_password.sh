#!/bin/bash
for server in `cat server-list.txt`
do
echo -e "Server IP is: $server"
ssh $server 'echo "user:********" | chpasswd '
done
