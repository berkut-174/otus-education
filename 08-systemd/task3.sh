#!/bin/bash

cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
sed -i '/^EnvironmentFile/s/$/-%i/' /usr/lib/systemd/system/httpd@.service
systemctl daemon-reload

cp /etc/sysconfig/httpd{,-first}
cp /etc/sysconfig/httpd{,-second}

sed -i '/^#*OPTIONS/s/#//;/^OPTIONS/s/$/-f conf\/first.conf/' /etc/sysconfig/httpd-first
sed -i '/^#*OPTIONS/s/#//;/^OPTIONS/s/$/-f conf\/second.conf/' /etc/sysconfig/httpd-second

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf

sed -i '/^Listen/s/[0-9]*$/8081/;/^Listen/a PidFile /var/run/httpd-first.pid' /etc/httpd/conf/first.conf
sed -i '/^Listen/s/[0-9]*$/8082/;/^Listen/a PidFile /var/run/httpd-second.pid' /etc/httpd/conf/second.conf

# configure selinux
yum install -y policycoreutils-python
semanage port -m -t http_port_t -p tcp 8082
semanage port -m -t http_port_t -p tcp 8081

systemctl start httpd@first httpd@second

ss -tnulp | grep httpd
