#!/bin/bash
#Ensure services are up and running
set -xe

chmod +x /opt/nomad/plugins/*

sed -i -e "s|^#*DefaultLimitNOFILE.*|DefaultLimitNOFILE=16384|g" /etc/systemd/system.conf
sed -i -e "s|^#*DefaultLimitNOFILE.*|DefaultLimitNOFILE=16384|g" /etc/systemd/user.conf
cat <<EOF>/etc/security/limits.conf
* - nofile 16384
root - nofile 16384
EOF

systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

