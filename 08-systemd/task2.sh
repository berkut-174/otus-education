#!/bin/bash

yum install -y epel-release

yum install -y \
    spawn-fcgi \
    php \
    php-cli \
    mod_fcgid \
    httpd

sed -i '/#SOCKET/s/^#*//;/#OPTIONS/s/^#*//' /etc/sysconfig/spawn-fcgi

cat > /usr/lib/systemd/system/spawn-fcgi.service <<__EOF__
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
__EOF__

systemctl start spawn-fcgi.service
systemctl status spawn-fcgi.service
