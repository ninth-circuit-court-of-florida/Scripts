#!/bin/bash -l
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
apt-get install wget

useradd node_exporter -s /sbin/nologin
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*.tar.gz
cp node_exporter-*.*/node_exporter /usr/sbin/

rm -rf /etc/systemd/system/node_exporter.service
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

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
