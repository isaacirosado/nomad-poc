#!/bin/bash
set -e

if [[ -d "/opt/nomad/plugins/" ]]; then
  chmod +x /opt/nomad/plugins/* || true
fi

systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

