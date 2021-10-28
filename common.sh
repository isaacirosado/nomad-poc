curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew nomad=1.1.6
apt-get install -y lxc lxc-templates lxd unzip

systemctl enable nomad

cat <<EOF | lxd init --preseed
config: {}
networks: []
storage_pools:
- config: {}
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    root:
      path: /
      pool: default
      type: disk
  name: default
cluster: null
EOF

mkdir -p /opt/nomad/plugins
curl -O https://releases.hashicorp.com/nomad-driver-lxc/0.1.0-rc2/nomad-driver-lxc_0.1.0-rc2_linux_amd64.zip
unzip nomad-driver-lxc_0.1.0-rc2_linux_amd64.zip
mv nomad-driver-lxc /opt/nomad/plugins/
rm -Rf ./nomad-driver-lxc*.zip
