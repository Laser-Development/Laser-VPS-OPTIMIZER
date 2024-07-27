#!/bin/bash

# Remove installed packages
apt purge curl unzip zip nano htop screen git fail2ban ufw libapache2-mod-fastcgi libapache2-mod-http2 libapache2-mod-brotli apache2-utils libapache2-mod-ssl -y

# Remove optimized configurations
sudo rm /etc/sysctl.conf /etc/ssh/ssh_config /etc/fail2ban/jail.conf /etc/mysql/my.cnf /etc/apache2/apache2.conf /etc/resolv.conf

# Disable and remove services
sudo systemctl disable apache2 mysql postfix exim4 fail2ban ufw

# Remove swap file
swapoff /swapfile
rm /swapfile

# Remove Badvpn (UDPGW) installation
rm /usr/local/bin/udpgw

# Clean up
apt autoremove -y
apt autoclean -y
