#!/bin/bash

dnf install -y epel-release

dnf install -y \
	gcc \
    gcc-c++ \
    gem \
    make \
	openssl-devel \
	pkg-config \
	redhat-rpm-config \
    ruby-devel \
	sqlite-devel \
    swaks

gem install mailcatcher

/usr/local/bin/mailcatcher --no-quit --ip 0.0.0.0

# cron
chmod +x /vagrant/parser.sh
echo '01 * * * * root /vagrant/parser.sh' > /etc/cron.d/parser
