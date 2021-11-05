#!/bin/bash
#Ensure services are up and running
set -xe

chmod +x /opt/nomad/plugins/*

sed -i -e "s|^#*DefaultLimitNOFILE.*|DefaultLimitNOFILE=2097152|g" /etc/systemd/system.conf
sed -i -e "s|^#*DefaultLimitNOFILE.*|DefaultLimitNOFILE=1048576|g" /etc/systemd/user.conf
cat <<EOF>/etc/security/limits.conf
session required pam_limits.so
* hard nofile 1048576
* soft nofile 1048576
EOF

systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

