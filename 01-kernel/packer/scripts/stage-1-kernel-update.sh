#!/bin/bash

# Import the public key
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# Install elrepo
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y
# Install new kernel
yum --enablerepo elrepo-kernel install kernel-ml kernel-ml-devel -y
# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now
