#/bin/bash

yum install -y \
    createrepo \
    gcc \
    gcc-c++ \
    redhat-lsb-core \
    rpmdevtools \
    rpm-build \
    wget \
    yum-utils

rpm -ivh https://nginx.org/packages/centos/7/SRPMS/nginx-1.20.2-1.el7.ngx.src.rpm

yum-builddep -y /root/rpmbuild/SPECS/nginx.spec
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1l.tar.gz
tar xf openssl-1.1.1l.tar.gz -C /root
sed -i -E '/ BASE_CONFIGURE_ARGS / s|(")| --with-openssl=/root/openssl-1.1.1l\1|2' /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
ls -1 /root/rpmbuild/RPMS/x86_64/
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.*.x86_64.rpm

mkdir -p /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.*.x86_64.rpm /usr/share/nginx/html/repo/
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /usr/share/nginx/html/repo/google-chrome-stable_current_x86_64.rpm
createrepo /usr/share/nginx/html/repo/
sed -i '/location \// a autoindex on;' /etc/nginx/conf.d/default.conf
nginx -t
systemctl enable --now nginx.service
# Daemon never wrote its PID file. Failing.
# Failed to start nginx - high performance web server.
# Unit nginx.service entered failed state.
# nginx.service failed.
systemctl restart nginx.service
curl -a http://localhost/repo/

yum-config-manager --add-repo http://localhost/repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/localhost_repo.repo
yum repolist enabled | grep localhost_repo
yum list | grep localhost_repo
yum install -y google-chrome-stable
rpm -q google-chrome-stable
