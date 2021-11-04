#!/bin/bash
#Update LXC image locally and trigger a cache update on all nodes
set -e

lxc-stop ghost >/dev/null 2>&1 || true
lxc-destroy ghost >/dev/null 2>&1 || true

apt-get install -y lxc lxc-templates
lxc-create -t`pwd`/template.sh -nghost

./sync.sh
