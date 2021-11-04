#!/bin/bash
#Initialize operating system
set -e
set -o errexit
set -o nounset
set -o pipefail

apt-get remove -y ufw
systemctl disable apparmor

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y nomad=1.1.6 consul
