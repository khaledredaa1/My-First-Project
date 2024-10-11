#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# SSet up the EPEL repository and install dependencies & required packages
sudo dnf install epel-release -y
sudo dnf install memcached -y

#Start and enable memcache
sudo systemctl enable memcached --now

# Configure memcached to listen on all interfaces
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

# Start and configure firewall to allow memcache access to ports 11211 tcp and 11111 udp
sudo systemctl enable firewalld --now
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --add-port=11111/udp --permanent
sudo firewall-cmd --reload

# Start memcached with custom UDP and TCP port settings
sudo memcached -p 11211 -U 11111 -u memcached -d