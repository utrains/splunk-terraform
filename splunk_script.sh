#!/bin/bash

sudo yum install wget
cd /opt
# Download the Splunk Enterprise tar file
sudo wget -O splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.0.4.1/linux/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz"

# Extract the tar file to /opt
sudo tar -zxvf splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz -C /opt

# Change ownership of the Splunk directory to the current user
#chown -R $(whoami):$(whoami) /opt/splunk
cd splunk/bin/
# Start Splunk Enterprise and set up the admin user and password
sudo ./splunk start --accept-license --answer-yes --no-prompt --seed-passwd "abcd1234"
sudo ./splunk enable listen 9997 -auth admin:"abcd1234"
#set the hostname
#sudo ./splunk set servername splunk-server
#enable splunk at the startup
sudo ./splunk enable boot-start

# Display the URL to access Splunk: we will look at it later!
#echo "Splunk is now installed and can be accessed at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000"
