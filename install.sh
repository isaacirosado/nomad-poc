#!/bin/bash
set -e

apt-get remove -y ufw

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y nomad=1.1.6 consul
snap install lxd --channel=4.0/stable >/dev/null 2>&1 || snap refresh lxd --channel=4.0/stable
apt-get install -y containerd lxc lxc-templates unzip

mkdir -p /opt/nomad/plugins
