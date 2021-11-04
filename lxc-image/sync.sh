#!/bin/bash
#Transfer LXC image cache to one (after creation) or all cluster clients (when image is updated locally)
set -xe

source /etc/profile.d/poc.sh
function transfer() {
  rsync -SHaAX -e "ssh $PDSH_SSH_ARGS_APPEND" /var/lib/lxc/ghost $1:/var/cache/lxc/
  pdcp -w$1 deployment-template.sh /opt/nomad/data/lxc-template.sh
}

if [[ ! -z "$1" ]]; then
  transfer $1
else
  for host in `doctl compute droplet list --format PublicIPv4 --no-header --tag-name client`; do
    transfer $host &
  done
  wait
fi
