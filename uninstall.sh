#!/bin/bash

# Remove installed packages
apt purge curl unzip zip nano htop screen git -y
apt purge fail2ban ufw -y
apt purge libapache2-mod-fastcgi libapache2-mod-http2 libapache2-mod-brotli apache2-utils -y
apt purge libapache2-mod-ssl -y

# Remove optimized configurations
rm /etc/sysctl.conf
rm /etc/ssh/ssh_config
rm /etc/fail2ban/jail.conf
rm /etc/mysql/my.cnf
rm /etc/apache2/apache2.conf
rm /etc/resolv.conf

# Disable and remove services
systemctl disable apache2
systemctl disable mysql
systemctl disable postfix
systemctl disable exim4
systemctl disable fail2ban
systemctl disable ufw

# Remove swap file
swapoff /swapfile
rm /swapfile

# Remove Badvpn (UDPGW) installation
rm /usr/local/bin/udpgw

# Clean up
apt autoremove -y
apt autoclean -y
