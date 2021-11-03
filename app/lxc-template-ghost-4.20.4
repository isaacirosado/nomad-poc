#!/bin/bash

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

try_rmsubvolume()
{
    path=$1
    [ -d $path ] || return 0
    rm -rf $path
}

configure_ubuntu()
{
    rootfs=$1
    hostname=$2
    release=$3
    user=$4
    password=$5

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

    # set the hostname
    cat <<EOF > $rootfs/etc/hostname
$hostname
EOF
    # set minimal hosts
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

    if [ ! -f $rootfs/etc/init/container-detect.conf ]; then
        # suppress log level output for udev
        sed -i "s/=\"err\"/=0/" $rootfs/etc/udev/udev.conf

        # remove jobs for consoles 5 and 6 since we only create 4 consoles in
        # this template
        rm -f $rootfs/etc/init/tty{5,6}.conf
    fi

    chroot $rootfs useradd --create-home -s /bin/bash $user
    echo "$user:$password" | chroot $rootfs chpasswd

    # make sure we have the current locale defined in the container
    if [ -z "$LANG" ] || echo $LANG | grep -E -q "^C(\..+)*$"; then
        chroot $rootfs locale-gen en_US.UTF-8 || true
        chroot $rootfs update-locale LANG=en_US.UTF-8 || true
    else
        chroot $rootfs locale-gen $LANG || true
        chroot $rootfs update-locale LANG=$LANG || true
    fi

    return 0
}

finalize_user()
{
    user=$1

    sudo_version=$(chroot $rootfs dpkg-query -W -f='${Version}' sudo)

    if chroot $rootfs dpkg --compare-versions $sudo_version gt "1.8.3p1-1"; then
        groups="sudo"
    else
        groups="sudo admin"
    fi

    for group in $groups; do
        chroot $rootfs groupadd --system $group >/dev/null 2>&1 || true
        chroot $rootfs adduser ${user} $group >/dev/null 2>&1 || true
    done

    return 0
}

write_sourceslist()
{
    # $1 => path to the partial cache or the rootfs
    # $2 => architecture we want to add
    # $3 => whether to use the multi-arch syntax or not

    case $2 in
      amd64|i386)
            MIRROR=${MIRROR:-http://archive.ubuntu.com/ubuntu}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://security.ubuntu.com/ubuntu}
            ;;
      *)
            MIRROR=${MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            ;;
    esac
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor > "$1/usr/share/keyrings/nodesource.gpg"
    if [ -n "$3" ]; then
        cat >> "$1/etc/apt/sources.list" << EOF
deb [arch=$2] $MIRROR ${release} main restricted universe multiverse
deb [arch=$2] $MIRROR ${release}-updates main restricted universe multiverse
deb [arch=$2] $SECURITY_MIRROR ${release}-security main restricted universe multiverse
EOF
    else
        cat >> "$1/etc/apt/sources.list" << EOF
deb $MIRROR ${release} main restricted universe multiverse
deb $MIRROR ${release}-updates main restricted universe multiverse
deb $SECURITY_MIRROR ${release}-security main restricted universe multiverse
EOF
    fi
    cat > "$1etc/apt/sources.list.d/node.list" << EOF
deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x ${release} main
deb-src [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x ${release} main
EOF
}

install_packages()
{
    local rootfs="$1"
    shift
    local packages="$*"
    if [ -z $update ]
    then
        chroot $rootfs apt-get update
        update=true
    fi
    if [ -n "${packages}" ]
    then
        chroot $rootfs apt-get install --allow-downgrades --allow-remove-essential --allow-change-held-packages -y --no-install-recommends ${packages}
    fi
}

cleanup()
{
    try_rmsubvolume $cache/partial-$arch
    try_rmsubvolume $cache/rootfs-$arch
}

suggest_flush()
{
    echo "Container upgrade failed.  The container cache may be out of date,"
    echo "in which case flushing the cache (see -F in the help output) may help."
}

download_ubuntu()
{
    cache=$1
    arch=$2
    release=$3

    case $2 in
      amd64|i386)
            MIRROR=${MIRROR:-http://archive.ubuntu.com/ubuntu}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://security.ubuntu.com/ubuntu}
            ;;
      *)
            MIRROR=${MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            ;;
    esac

    packages_template=${packages_template:-"apt-transport-https,vim"}
    debootstrap_parameters=

    # Try to guess a list of langpacks to install
    langpacks="language-pack-en"

    if which dpkg >/dev/null 2>&1; then
        langpacks=`(echo $langpacks &&
                    dpkg -l | grep -E "^ii  language-pack-[a-z]* " |
                        cut -d ' ' -f3) | sort -u`
    fi
    packages_template="${packages_template},$(echo $langpacks | sed 's/ /,/g')"

    if [ -n "$variant" ]; then
        debootstrap_parameters="$debootstrap_parameters --variant=$variant"
    fi
    if [ "$variant" = 'minbase' ]; then
        packages_template="${packages_template},sudo"
        # Newer releases use netplan, EOL releases not supported
        case $release in
          trusty|xenial|zesty)
                packages_template="${packages_template},ifupdown,isc-dhcp-client"
                ;;
        esac
    fi

    echo "Installing packages in template: ${packages_template}"

    trap cleanup EXIT SIGHUP SIGINT SIGTERM
    # check the mini ubuntu was not already downloaded
    try_mksubvolume "$cache/partial-$arch"
    if [ $? -ne 0 ]; then
        echo "Failed to create '$cache/partial-$arch' directory"
        return 1
    fi

    # download a mini ubuntu into a cache
    echo "Downloading ubuntu $release minimal ..."
    if [ -n "$(which qemu-debootstrap)" ]; then
        qemu-debootstrap --verbose $debootstrap_parameters --components=main,universe --arch=$arch --include=${packages_template} $release $cache/partial-$arch $MIRROR
    else
        debootstrap --verbose $debootstrap_parameters --components=main,universe --arch=$arch --include=${packages_template} $release $cache/partial-$arch $MIRROR
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to download the rootfs, aborting."
            return 1
    fi

    # Serge isn't sure whether we should avoid doing this when
    # $release == `distro-info -d`
    echo "Installing updates"
    > $cache/partial-$arch/etc/apt/sources.list
    write_sourceslist $cache/partial-$arch/ $arch

    chroot "$1/partial-${arch}" apt-get update
    if [ $? -ne 0 ]; then
        echo "Failed to update the apt cache"
        return 1
    fi
    cat > "$1/partial-${arch}"/usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 101
EOF
    chmod +x "$1/partial-${arch}"/usr/sbin/policy-rc.d

    (
        cat << EOF
        mount -t proc proc "${1}/partial-${arch}/proc"
        chroot "${1}/partial-${arch}" apt-get dist-upgrade -y
EOF
    ) | lxc-unshare -s MOUNT -- sh -eu || (suggest_flush; false)

    rm -f "$1/partial-${arch}"/usr/sbin/policy-rc.d

    chroot "$1/partial-${arch}" apt-get clean

    mv "$1/partial-$arch" "$1/rootfs-$arch"
    trap EXIT
    trap SIGINT
    trap SIGTERM
    trap SIGHUP
    echo "Download complete"
    return 0
}

copy_ubuntu()
{
    cache=$1
    arch=$2
    rootfs=$3

    # make a local copy of the miniubuntu
    echo "Copying rootfs to $rootfs ..."
    try_mksubvolume $rootfs
    rsync -SHaAX $cache/rootfs-$arch/ $rootfs/ || return 1
    return 0
}

install_ubuntu()
{
    rootfs=$1
    release=$2
    flushcache=$3
    cache="$4/$release"
    mkdir -p $LOCALSTATEDIR/lock/subsys/

    (
        flock -x 9
        if [ $? -ne 0 ]; then
            echo "Cache repository is busy."
            return 1
        fi


        if [ $flushcache -eq 1 ]; then
            echo "Flushing cache..."
            try_rmsubvolume $cache/partial-$arch
            try_rmsubvolume $cache/rootfs-$arch
        fi

        echo "Checking cache download in $cache/rootfs-$arch ... "
        if [ ! -e "$cache/rootfs-$arch" ]; then
            download_ubuntu $cache $arch $release
            if [ $? -ne 0 ]; then
                echo "Failed to download 'ubuntu $release base'"
                return 1
            fi
        fi

        echo "Copy $cache/rootfs-$arch to $rootfs ... "
        copy_ubuntu $cache $arch $rootfs
        if [ $? -ne 0 ]; then
            echo "Failed to copy rootfs"
            return 1
        fi

        return 0

    ) 9>$LOCALSTATEDIR/lock/subsys/lxc-ubuntu$release

    return $?
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

post_process()
{
    rootfs=$1
    release=$2

    # Disable service startup
    cat > $rootfs/usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 101
EOF
    chmod +x $rootfs/usr/sbin/policy-rc.d

    if [ ! -L $rootfs/dev/shm ] && [ -e $rootfs/dev/shm ]; then
      rmdir $rootfs/dev/shm 2>/dev/null || mv $rootfs/dev/shm $rootfs/dev/shm.bak
      ln -s /run/shm $rootfs/dev/shm
    fi

    # Set initial timezone as on host
    cat /etc/timezone > $rootfs/etc/timezone
    chroot $rootfs dpkg-reconfigure -f noninteractive tzdata

    # Re-enable service startup
    rm $rootfs/usr/sbin/policy-rc.d
}

options=$(getopt -o p:F -l path:,release:,name:,flush-cache,rootfs: -- "$@")
eval set -- "$options"

. /etc/lsb-release
release=$DISTRIB_CODENAME
arch=`/usr/bin/dpkg --print-architecture`
hostarch=$arch
flushcache=0
user="node"
password="everythingisawesome9"

while true
do
    case "$1" in
      --rootfs)       rootfs=$2; shift 2;;
      -p|--path)      path=$2; shift 2;;
      -n|--name)      name=$2; shift 2;;
      -F|--flush-cache) flushcache=1; shift 1;;
      -r|--release)   release=$2; shift 2;;
      --port)         port=$2; shift 2;;
      --url)          url=$2; shift 2;;
      --)             shift 1; break ;;
      *)              break ;;
    esac
done

which debootstrap >/dev/null 2>&1 || { echo "'debootstrap' command is missing" >&2; false; }

if [ -z "$path" ]; then
    echo "'path' parameter is required"
    exit 1
fi

config="$path/config"
export DEBIAN_FRONTEND=noninteractive

install_ubuntu $rootfs $release $flushcache $LXC_CACHE_PATH
mount -t proc proc $rootfs/proc
chroot $rootfs mount -t devpts devpts /dev/pts

configure_ubuntu $rootfs $name $release $user $password

copy_configuration $path $rootfs $name $arch $release

post_process $rootfs $release

finalize_user $user

export update="1"
install_packages $rootfs nodejs consul

export GHOST_INSTALL="/var/www/site"
export GHOST_CONTENT="${GHOST_INSTALL}/content"
export GHOST_VERSION="4.20.4"
chroot $rootfs /bin/bash -x <<EOF
mkdir -p ${GHOST_INSTALL}
chown -Rf ${user}:${user} ${GHOST_INSTALL}
npm install ghost-cli@latest -g
su ${user} -c "ghost install ${GHOST_VERSION} --db=sqlite3 --no-prompt --no-check-mem --no-stack --no-setup --dir ${GHOST_INSTALL}"
EOF

cat <<EOF > $rootfs/etc/systemd/system/ghost.service
[Unit]
Description=Ghost systemd service
Documentation=https://docs.ghost.org

[Service]
Type=simple
WorkingDirectory=${GHOST_INSTALL}
User=${user}
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node current/index.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF
chroot $rootfs systemctl enable ghost

umount $rootfs/proc

#Ugly hacks around DigitalOcean's forceful key-on-every-table setting
cd ${rootfs}${GHOST_INSTALL}/versions/${GHOST_VERSION}
cat <<'EOF' > lock-table-js.diff
--- node_modules/knex-migrator/migrations/lock-table.js.bkp     2021-11-02 09:46:35.625371303 +0000
+++ node_modules/knex-migrator/migrations/lock-table.js 2021-11-02 09:47:21.417947506 +0000
@@ -15,7 +15,7 @@
             }

             return connection.schema.createTable('migrations_lock', function (table) {
-                table.string('lock_key', 191).nullable(false).primary();
+                table.specificType('lock_key', 'char(64) primary key');
                 table.boolean('locked').default(0);
                 table.dateTime('acquired_at').nullable();
                 table.dateTime('released_at').nullable();
EOF
patch -f node_modules/knex-migrator/migrations/lock-table.js < lock-table-js.diff

cat <<'EOF' > commands-js.diff
--- core/server/data/schema/commands.js.old     2021-11-02 09:42:48.862517114 +0000
+++ core/server/data/schema/commands.js 2021-11-02 09:43:51.095300590 +0000
@@ -312,11 +312,13 @@
  */
 function createTable(table, transaction, tableSpec = schema[table]) {
     return (transaction || db.knex).schema.hasTable(table)
-        .then(function (exists) {
+        .then(async function (exists) {
             if (exists) {
                 return;
             }

+           await (transaction || db.knex).raw('SET sql_require_primary_key=0');
+
             return (transaction || db.knex).schema.createTable(table, function (t) {
                 Object.keys(tableSpec)
                     .filter(column => !(column.startsWith('@@')))
EOF
patch -f core/server/data/schema/commands.js < commands-js.diff

