#!/bin/bash

# Update OS with the latest patches
sudo apt update -y
sudo apt upgrade -y
sudo vim
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration file for the app
sudo tee /etc/nginx/sites-available/vproapp > /dev/null <<EOL
upstream vproapp {
    server app01:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOL

# Remove default Nginx configuration and enable the new site
sudo mv vproapp /etc/nginx/sites-available/vproapp
sudo rm -rf /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# Restart Nginx to apply changes
sudo systemctl enable nginx --now
sudo systemctl restart nginx