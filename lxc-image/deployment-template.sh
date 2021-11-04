#!/bin/bash
set -x

# Make sure the usual locations are in PATH
export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin

LOCALSTATEDIR="/var"
LXC_TEMPLATE_CONFIG="/usr/share/lxc/config"
LXC_CACHE_PATH=${LXC_CACHE_PATH:-"$LOCALSTATEDIR/cache/lxc"}

if [ -r /etc/default/lxc ]; then
    . /etc/default/lxc
fi

try_mksubvolume()
{
    path=$1
    [ -d $path ] && return 0
    mkdir -p $(dirname $path)
    mkdir -p $path
}

configure_ubuntu()
{
    rootfs=$1
    hostname=$2
    release=$3

    # configure the network using the dhcp
    if chroot $rootfs which netplan >/dev/null 2>&1; then
        cat <<EOF > $rootfs/etc/netplan/10-lxc.yaml
network:
  ethernets:
    eth0: {dhcp4: true}
  version: 2
EOF
    else
        cat <<EOF > $rootfs/etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
    fi

    cat <<EOF > $rootfs/etc/hostname
$hostname
EOF
    cat <<EOF > $rootfs/etc/hosts
127.0.0.1   localhost
127.0.1.1   $hostname

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
}

copy_configuration()
{
    path=$1
    rootfs=$2
    name=$3
    arch=$4
    release=$5

    if [ $arch = "i386" ]; then
        arch="i686"
    fi

    # if there is exactly one veth network entry, make sure it has an
    # associated hwaddr.
    nics=`grep -e '^lxc\.net\.0\.type[ \t]*=[ \t]*veth' $path/config | wc -l`
    if [ $nics -eq 1 ]; then
        grep -q "^lxc.net.0.hwaddr" $path/config || sed -i -e "/^lxc\.net\.0\.type[ \t]*=[ \t]*veth/a lxc.net.0.hwaddr = 00:16:3e:$(openssl rand -hex 3| sed 's/\(..\)/\1:/g; s/.$//')" $path/config
    fi

    # Generate the configuration file
    ## Relocate all the network config entries
    sed -i -e "/lxc.net.0/{w ${path}/config-network" -e "d}" $path/config

    ## Relocate any other config entries
    sed -i -e "/lxc./{w ${path}/config-auto" -e "d}" $path/config

    ## Add all the includes
    echo "" >> $path/config
    echo "# Common configuration" >> $path/config
    if [ -e "${LXC_TEMPLATE_CONFIG}/ubuntu.common.conf" ]; then
        echo "lxc.include = ${LXC_TEMPLATE_CONFIG}/ubuntu.common.conf" >> $path/config
    fi
    if [ -e "${LXC_TEMPLATE_CONFIG}/ubuntu.${release}.conf" ]; then
        echo "lxc.include = ${LXC_TEMPLATE_CONFIG}/ubuntu.${release}.conf" >> $path/config
    fi

    ## Add the container-specific config
    echo "" >> $path/config
    echo "# Container specific configuration" >> $path/config
    [ -e "$path/config-auto" ] && cat $path/config-auto >> $path/config && rm $path/config-auto
    grep -q "^lxc.rootfs.path" $path/config 2>/dev/null || echo "lxc.rootfs.path = $rootfs" >> $path/config
    cat <<EOF >> $path/config
lxc.uts.name = $name
lxc.arch = $arch
EOF

    ## Re-add the previously removed network config
    echo "" >> $path/config
    echo "# Network configuration" >> $path/config
    cat $path/config-network >> $path/config
    rm $path/config-network

    if [ $? -ne 0 ]; then
        echo "Failed to add configuration"
        return 1
    fi

    return 0
}

options=$(getopt -o p: -l path:,name:,rootfs:,shortname:,domain:,dbhost:,dbuser:,dbpass:,dbport:,dbname: -- "$@")
eval set -- "$options"

. /etc/lsb-release
release=$DISTRIB_CODENAME
arch=`/usr/bin/dpkg --print-architecture`
while true
do
    case "$1" in
      -p|--path)      path=$2; shift 2;;
      --name) name=$2; shift 2;;
      --rootfs) rootfs=$2; shift 2;;
      --shortname) shortname=$2; shift 2;;
      --domain) domain=$2; shift 2;;
      --dbhost) dbhost=$2; shift 2;;
      --dbuser) dbuser=$2; shift 2;;
      --dbpass) dbpass=$2; shift 2;;
      --dbport) dbport=$2; shift 2;;
      --dbname) dbname=$2; shift 2;;
      --) shift 1; break;;
      *) break;;
    esac
done

if [ -z "$rootfs" ]; then
    echo "'rootfs' parameter is required"
    exit 1
fi
if [ -z "$path" ]; then
    echo "'path' parameter is required"
    exit 1
fi

config="$path/config"
export DEBIAN_FRONTEND=noninteractive

try_mksubvolume $rootfs
rsync -SHaAX --no-specials --no-devices $LXC_CACHE_PATH/ghost/rootfs/ $rootfs/

configure_ubuntu $rootfs $name $release
copy_configuration $path $rootfs $name $arch $release

export GHOST_INSTALL="/var/www/site"

cat <<EOF > ${rootfs}${GHOST_INSTALL}/config.production.json
{
  "url": "http://${shortname}.${domain}",
  "server": {
    "port": "2368",
    "host": "0.0.0.0"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "${dbhost}",
      "port": ${dbport},
      "user": "${dbuser}",
      "password": "${dbpass}",
      "database": "${dbname}"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "systemd",
  "paths": {
    "contentPath": "${GHOST_INSTALL}/content"
  }
}
EOF

