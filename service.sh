#!/bin/bash

set -e

if [[ -s "/opt/nomad/plugins/nomad-driver-lxc" ]]; then
  chmod +x /opt/nomad/plugins/nomad-driver-lxc
fi
systemctl enable nomad
systemctl start nomad
