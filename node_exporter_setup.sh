#!/bin/bash -e

# Ensure the script is run as root
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Update and install required packages
apt-get update
apt-get install -y wget curl jq

# Get the latest version
queryVersion=$(curl --silent https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name)
latestVersion="${queryVersion:1}"
downloadURL="https://github.com/prometheus/node_exporter/releases/download/${queryVersion}/node_exporter-${latestVersion}.linux-amd64.tar.gz"

# Setup user
useradd --no-create-home --shell /sbin/nologin node_exporter

# Download, extract, and install
cd /tmp/
wget --content-disposition --quiet $downloadURL
tar xvfz node_exporter-*.*.tar.gz >/dev/null
cp node_exporter-*.*/node_exporter /usr/sbin/
rm -rf node_exporter*

# Configure systemd service
cat > /etc/systemd/system/node_exporter.service <<EOT
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=-/etc/sysconfig/node_exporter
ExecStart=/usr/sbin/node_exporter \$OPTIONS

[Install]
WantedBy=multi-user.target
EOT

# Create default options file
mkdir -p /etc/sysconfig
touch /etc/sysconfig/node_exporter

# Enable and start the service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Finished
echo "Node Exporter installed"
