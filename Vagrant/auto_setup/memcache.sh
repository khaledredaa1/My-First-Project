#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# Install and start memcache on port 11211
sudo dnf install epel-release -y
sudo dnf install memcached -y
sudo systemctl enable memcached --now

# Configure memcached to listen on all interfaces
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

# Start and configure firewall to allow access to memcache on TCP and UDP ports
sudo systemctl enable firewalld --now
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --add-port=11111/udp --permanent
sudo firewall-cmd --reload

# Start memcached with custom UDP and TCP port settings
sudo memcached -p 11211 -U 11111 -u memcached -d