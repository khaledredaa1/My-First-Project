#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# Set Repository and install dependencies
sudo yum install epel-release -y
sudo dnf -y install java-11-openjdk java-11-openjdk-devel
sudo dnf install git maven wget -y

# Download and extract Tomcat package
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`

# Add Tomcat user and set up Tomcat home directory
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat

rm -rf /etc/systemd/system/tomcat.service

# Create systemd service for Tomcat
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOL
[Unit]
Description=Tomcat
After=network.target

[Service]
Group=tomcat

WorkingDirectory=/usr/local/tomcat

#Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

EOL

# Reload systemd files and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat --now

# Download source code and build project
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

# Update application.properties with backend server details (this can be modified based on your configuration)
# Replace 'vim' with 'sed' if automatic changes are needed in future
vim src/main/resources/application.properties

# Build the project
mvn install

# Deploy the WAR file to Tomcat
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
sudo chown -R tomcat:tomcat /usr/local/tomcat/webapps

# Start and configure firewall to allow Tomcat access to port 8080
sudo systemctl enable firewalld --now
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Restart Tomcat after firewall configuration
sudo systemctl restart tomcat