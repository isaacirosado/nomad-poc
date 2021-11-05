#!/bin/bash
# Local setup for cluster operations
set -e
set -o errexit
set -o nounset
set -o pipefail

apt-get install -y nomad=1.1.6 consul pdsh

#In lieu of proper DNS, use local resolution to find nodes by shortname
cat <<EOF> /etc/hosts
127.0.1.1 isaac-rosado isaac-rosado
127.0.0.1 localhost

::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

#PoC
EOF
doctl compute droplet list --format PublicIPv4,Name --no-header --tag-name=cluster >> /etc/hosts
truncate -s0 /root/.ssh/known_hosts

#Set ENV vars to find cluster services
cat <<EOF>/etc/profile.d/poc.sh
export PDSH_SSH_ARGS_APPEND="-i /root/.ssh/id_rsa -oStrictHostKeyChecking=no"
export PDSH_RCMD_TYPE="ssh"
export TF_VAR_do_token="`grep -e "access-token" /root/.config/doctl/config.yaml | sed -re "s|.*\s||g"`"
export NOMAD_ADDR="http://`doctl compute droplet list --format Name,PrivateIPv4 --no-header --tag-name client | grep client0 | head -n1 | awk '{print $2;}'`:4646"
export NOMAD_TOKEN=""
export CONSUL_HTTP_ADDR="http://`doctl compute droplet list --format Name,PrivateIPv4 --no-header --tag-name client | grep client0 | head -n1 | awk '{print $2;}'`:8500"

if [[ -d ~/nomad-poc ]]; then
  cd ~/nomad-poc
fi
EOF
source /etc/profile.d/poc.sh

#Update local groups to match DO's tags so we can target by groups
doctl compute droplet list --format Name,Tags --no-header --tag-name=cluster > /etc/genders
