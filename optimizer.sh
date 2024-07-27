#!/bin/bash

# Upgrade and update the system
apt update -y && apt full-upgrade -y

# Install useful packages
sudo apt install -y curl unzip zip nano htop screen git ufw

# Optimize SYSCTL
cat > /tmp/sysctl_params.txt << EOF
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

sudo mv /tmp/sysctl_params.txt /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# Optimize SSH
echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config
echo "ServerAliveCountMax 5" >> /etc/ssh/ssh_config
service ssh restart

# TCP congestion control (Tcp-brutal, Tcp-BBR, XanMod-BBRv3, OpenVZ-BBR)
bash <(curl -s https://raw.githubusercontent.com/opiran-club/VPS-Optimizer/main/optimizer.sh --ipv4)

# Swap file + vm.swapiness value
cat > /tmp/swap_setup.sh << EOF
#!/bin/bash
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "vm.swappiness = 10" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
EOF

sudo bash /tmp/swap_setup.sh

# Badvpn (UDPGW) installation
wget -N https://raw.githubusercontent.com/opiran-club/VPS-Optimizer/main/Install/udpgw.sh
bash udpgw.sh

# Install and configure Fail2Ban
cat > /tmp/fail2ban_setup.sh << EOF
#!/bin/bash
apt install fail2ban -y
echo "[DEFAULT]" | sudo tee -a /etc/fail2ban/jail.conf
echo "bantime = 3600" | sudo tee -a /etc/fail2ban/jail.conf
echo "findtime = 600" | sudo tee -a /etc/fail2ban/jail.conf
echo "maxretry = 3" | sudo tee -a /etc/fail2ban/jail.conf
sudo systemctl restart fail2ban
EOF

sudo bash /tmp/fail2ban_setup.sh

# Install and configure UFW
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable
service ufw restart

# Optimize MySQL (if installed)
if [ -f /etc/mysql/my.cnf ]; then
  echo "innodb_buffer_pool_size = 128M" >> /etc/mysql/my.cnf
  echo "innodb_log_file_size = 50M" >> /etc/mysql/my.cnf
  service mysql restart
fi

# Optimize Apache (if installed)
if [ -f /etc/apache2/apache2.conf ]; then
  echo "KeepAlive On" >> /etc/apache2/apache2.conf
  echo "MaxKeepAliveRequests 100" >> /etc/apache2/apache2.conf
  echo "KeepAliveTimeout 5" >> /etc/apache2/apache2.conf
  service apache2 restart
fi

# Clean up
apt autoremove -y
apt autoclean -y

# Speed up DNS resolution
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Disable unnecessary services
systemctl disable apache2
systemctl disable mysql
systemctl disable postfix
systemctl disable exim4

# Enable fastcgi
apt install libapache2-mod-fastcgi -y
a2enmod fastcgi
service apache2 restart

# Enable HTTP/2
apt install libapache2-mod-http2 -y
a2enmod http2
service apache2 restart

# Enable brotli compression
apt install libapache2-mod-brotli -y
a2enmod brotli
service apache2 restart

# Enable gzip compression
a2enmod deflate
service apache2 restart

# Enable caching
apt install apache2-utils -y
a2enmod cache
service apache2 restart

# Enable expires headers
a2enmod expires
service apache2 restart

# Enable headers module
a2enmod headers
service apache2 restart

# Enable SSL/TLS
apt install libapache2-mod-ssl
