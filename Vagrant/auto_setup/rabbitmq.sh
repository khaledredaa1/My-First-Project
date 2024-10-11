#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# SSet up the EPEL repository and install dependencies & required packages
sudo yum install epel-release -y
sudo yum install wget -y

# Install RabbitMQ repository and RabbitMQ server
cd /tmp/
sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable rabbitmq-server --now

# Setup access for user 'test' and make it an admin
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." | sudo tee /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server

# Start and configure firewall to allow RabbitMQ access to port 5672
sudo systemctl enable firewalld --now
sudo firewall-cmd --add-port=5672/tcp --permanent
sudo firewall-cmd --reload

# Ensure RabbitMQ service is running and enabled
sudo systemctl enable rabbitmq-server --now