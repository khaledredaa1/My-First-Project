#!/bin/bash

# Update OS with the latest patches
sudo yum update -y

# Set Repository and install dependencies
sudo yum install epel-release -y
sudo dnf -y install java-11-openjdk java-11-openjdk-devel
sudo dnf install git maven wget -y

# Download and extract Tomcat package
cd /tmp/
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz

# Add Tomcat user and set up Tomcat home directory
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
sudo mkdir -p /usr/local/tomcat
sudo cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat

# Create systemd service for Tomcat
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOL
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd files and start Tomcat
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Start and configure firewall to allow access to Tomcat on port 8080
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Download source code and build project
cd /home/vagrant
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
sudo systemctl restart tomcat
