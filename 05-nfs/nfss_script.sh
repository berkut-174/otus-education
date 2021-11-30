#!/bin/bash

yum install -y nfs-utils

systemctl enable --now firewalld

firewall-cmd --add-service="nfs3" \
    --add-service="rpc-bind" \
    --add-service="mountd" \
    --permanent

firewall-cmd --reload

mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

echo '/srv/share 192.168.50.11/32(rw,sync,root_squash)' > /etc/exports

systemctl enable --now nfs
