#!/bin/bash
set -e

#Update LXC image

lxc-stop ghost >/dev/null 2>&1 || true
lxc-destroy ghost >/dev/null 2>&1 || true

apt-get install -y lxc lxc-templates
lxc-create -t`pwd`/template.sh -nghost

#Trigger cluster refresh

./sync.sh
