#!/usr/bin/env bash

cat <<__EOF__ | nsupdate -k /etc/named.zonetransfer.key
server 192.168.50.10
zone ddns.lab
update add www.ddns.lab. 60 A 192.168.50.15
send
quit
__EOF__
