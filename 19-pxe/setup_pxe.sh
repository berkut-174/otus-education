#!/usr/bin/env bash

yum install -y epel-release

yum install -y \
    dhcp \
    nginx \
    tftp-server \
    syslinux-tftpboot

cat > /etc/dhcp/dhcpd.conf <<__EOF__
option space pxelinux;
option pxelinux.magic code 208 = string;
option pxelinux.configfile code 209 = text;
option pxelinux.pathprefix code 210 = text;
option pxelinux.reboottime code 211 = unsigned integer 32;
option architecture-type code 93 = unsigned integer 16;
subnet 10.0.0.0 netmask 255.255.255.0 {
	#option routers 10.0.0.254;
	range 10.0.0.100 10.0.0.120;
	class "pxeclients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
        next-server 10.0.0.20;
        if option architecture-type = 00:07 {
            filename "uefi/shim.efi";
        } else {
            filename "pxelinux/pxelinux.0";
        }
	}
}
__EOF__

mkdir /var/lib/tftpboot/pxelinux
cp /var/lib/tftpboot/pxelinux.0 /var/lib/tftpboot/pxelinux
cp /var/lib/tftpboot/menu.c32 /var/lib/tftpboot/pxelinux

mkdir /var/lib/tftpboot/pxelinux/pxelinux.cfg
cat > /var/lib/tftpboot/pxelinux/pxelinux.cfg/default <<__EOF__
default menu
prompt 0
timeout 100
MENU TITLE Demo PXE setup
LABEL linux
  menu label ^Install system
  menu default
  kernel images/CentOS-8/vmlinuz
  initrd images/CentOS-8/initrd.img
  append inst.repo=https://mirror.yandex.ru/centos/8-stream/BaseOS/x86_64/os/ inst.ks=http://10.0.0.20/ks.cfg
__EOF__

mkdir -p /var/lib/tftpboot/pxelinux/images/CentOS-8/
pushd /var/lib/tftpboot/pxelinux/images/CentOS-8/
curl -O https://mirror.yandex.ru/centos/8-stream/BaseOS/x86_64/os/images/pxeboot/initrd.img
curl -O https://mirror.yandex.ru/centos/8-stream/BaseOS/x86_64/os/images/pxeboot/vmlinuz
popd
cp /vagrant/ks.cfg /usr/share/nginx/html/

systemctl enable --now \
    dhcpd.service \
    nginx \
    tftp.service
