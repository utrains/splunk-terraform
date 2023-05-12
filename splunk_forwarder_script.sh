#!/bin/bash

cd /opt
# Download the Splunk Universal Forwarder package
sudo wget -O splunkforwarder-9.0.4-de405f4a7979-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.4/linux/splunkforwarder-9.0.4-de405f4a7979-Linux-x86_64.tgz"

# Extract the package
sudo tar -xvzf splunkforwarder-9.0.4-de405f4a7979-Linux-x86_64.tgz -C /opt
cd /splunkforwarder/bin/
sudo ./splunk disable boot-start
sudo groupadd splunk #create the group splunk
sudo useradd -m -d /home/splunk splunk -g splunk #create the user splunk and bing it to the group splunk
sudo chown -R splunk:splunk /opt/splunkforwarder
sudo ./splunk enable boot-start -systemd-managed 1 -user splunk -group splunk

# Change ownership of the Splunk directory to the current user
#chown -R $(whoami):$(whoami) /opt/splunkforwarder

# Install the Splunk Universal Forwarder
#sudo /opt/splunkforwarder/bin/splunk install --accept-license --answer-yes --no-prompt
#sudo ./splunk edit user splunk -password abcd1234 -auth admin:changeme

# Configure the Splunk Universal Forwarder to send data to a Splunk Enterprise instance
#/opt/splunkforwarder/bin/splunk add forward-server <splunk_server>:<splunk_port>
#/opt/splunkforwarder/bin/splunk add monitor /var/log/syslog

# Start the Splunk Universal Forwarder
#sudo ./opt/splunkforwarder/bin/splunk restart

# Display the URL to access Splunk Forwarder
#echo "The Forwarder is now installed and can be accessed at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9997"
