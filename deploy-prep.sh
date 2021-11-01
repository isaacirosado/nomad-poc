#!/bin/bash
set -e
set -o errexit
set -o nounset
set -o pipefail

apt-get install -y pdsh

#Update local resolution to ease up on operations
cat etc-hosts > /etc/hosts

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

#Update local groups to match DO's tags
doctl compute droplet list --format Name,Tags --no-header --tag-name=cluster > /etc/genders

#Copy LXC template (and cache build)
chmod +x app/lxc-template
pdcp -pg client app/lxc-template /opt/nomad/data/
#pdsh -gclient bash --login -c \"lxc-stop -nubuntu\; lxc-destroy -nubuntu\"
#pdsh -gclient bash --login -c \"lxc-create -nubuntu -t /usr/share/lxc/templates/lxc-ubuntu\"
#pdsh -gclient bash --login -c \"lxc-destroy -nubuntu\"
