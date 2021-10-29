#!/bin/bash
set -e

if [[ -s "/opt/nomad/plugins/nomad-driver-lxc" ]]; then
  chmod +x /opt/nomad/plugins/nomad-driver-lxc
fi
systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

