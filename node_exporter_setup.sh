#!/bin/bash -l
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
apt-get install wget curl jq

# Get Latest Version
queryVersion=`curl --silent https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name`
latestVersion="${queryVersion:1}"
downloadURL="https://github.com/prometheus/prometheus/releases/download/${queryVersion}/node_exporter-${latestVersion}.linux-amd64.tar.gz"

# Setup User
useradd node_exporter -s /sbin/nologin

# Install
cd /tmp/
wget --content-disposition $downloadURL
tar xvfz node_exporter-*.*.tar.gz
cp node_exporter-*.*/node_exporter /usr/sbin/
rm -rf node_exporter*

# Configure
rm /etc/systemd/system/node_exporter.service
touch /etc/systemd/system/node_exporter.service
tee -a /etc/systemd/system/node_exporter.service > /dev/null <<EOT
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/sbin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
EOT

mkdir -p /etc/sysconfig
touch /etc/sysconfig/node_exporter

# Create and start service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Finished
echo "node_exporter installed"
