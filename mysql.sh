#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# Set Repository and install required packages
sudo yum install epel-release -y
sudo yum install git mariadb-server -y

# Start and enable mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF
Y
admin123
admin123
Y
n
Y
Y
EOF

# Set up the database and users
sudo mysql -u root -padmin123 <<MYSQL_SCRIPT
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Clone the vProfile project and initialize the database
cd /home/vagrant
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql

# Restart mariadb-server
sudo systemctl restart mariadb

# Start and configure firewall to allow access to MariaDB
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

# Restart mariadb-server after firewall configuration
sudo systemctl restart mariadb
