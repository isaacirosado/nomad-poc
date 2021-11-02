#!/bin/bash
set -e
set -o errexit
set -o nounset
set -o pipefail

apt-get install -y pdsh

#Update local resolution to ease up on operations
cat etc-hosts > /etc/hosts
truncate -s0 /root/.ssh/known_hosts

echo "" >> /etc/hosts
echo "#POC" >> /etc/hosts
doctl compute droplet list --format PublicIPv4,Name --no-header --tag-name=cluster >> /etc/hosts

#Set vars
cat <<EOF>/etc/profile.d/poc.sh
export PDSH_SSH_ARGS_APPEND="-i /root/.ssh/id_rsa -oStrictHostKeyChecking=accept-new"
export PDSH_RCMD_TYPE="ssh"
export TF_VAR_do_token="`grep -e "access-token" /root/.config/doctl/config.yaml | sed -re "s|.*\s||g"`"
export NOMAD_ADDR="http://`doctl compute droplet list --format Name,PrivateIPv4 --no-header --tag-name client | grep client0 | awk '{print $2;}'`:4646"
EOF
source /etc/profile.d/poc.sh

#Update local groups to match DO's tags
doctl compute droplet list --format Name,Tags --no-header --tag-name=cluster > /etc/genders

#Copy LXC template (and cache build)
export GHOST_VERSION="4.20.4"
chmod +x app/lxc-template-*
pdcp -pgclient app/lxc-template-* /opt/nomad/data/
pdsh -gclient bash --login -c \"lxc-info ghost-${GHOST_VERSION} \|\| lxc-create -t/opt/nomad/data/lxc-template-ghost-${GHOST_VERSION} -nghost-${GHOST_VERSION}\"
