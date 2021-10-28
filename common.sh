set -e

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y nomad=1.1.6
snap install lxd --channel=3.0/stable >/dev/null 2>&1 || snap refresh lxd --channel=3.0/stable
apt-get install -y lxc-templates unzip

mkdir -p /opt/nomad/plugins
curl -O https://releases.hashicorp.com/nomad-driver-lxc/0.1.0-rc2/nomad-driver-lxc_0.1.0-rc2_linux_amd64.zip
unzip nomad-driver-lxc_0.1.0-rc2_linux_amd64.zip
mv nomad-driver-lxc /opt/nomad/plugins/
rm -Rf ./nomad-driver-lxc*.zip
