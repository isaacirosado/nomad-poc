# nomad-poc

## Basic requirements

This provisioning system is based on using Digital Ocean from an Linux server:

- Get an account at https://cloud.digitalocean.com/registrations/new
- Generate a token (instructions: https://docs.digitalocean.com/reference/api/create-personal-access-token/)
- Define the token as an environment variable (e.g. in Linux: `export DIGITALOCEAN_TOKEN="YOUR_TOKEN_HERE"`)
  - Security tip: In Linux, by default commands starting with a "space" are not logged in the history ;-)
- Install Digital Ocean's CLI per https://docs.digitalocean.com/reference/doctl/ 

We are provisioning/configuring most everything with Hashicorp's Terraform:

- Install Terraform per https://learn.hashicorp.com/tutorials/terraform/install-cli, e.g. for Linux:
  ```
  apt-get update && apt-get install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt-get update && apt-get install terraform
  ```

- Install "PDSH" so you can run commands on multiple hosts at the same time
  ```
  apt-get install -y pdsh
  ```

- Other tools
  - "nomad" (as a client to manage deployments), make sure to use the same version as the cluster
  - "dig" for DNS queries

## Deployment

- Compile the LXC driver for Nomad (because of this bug: https://github.com/hashicorp/nomad-driver-lxc/issues/16 that renders it incompatible with LXC v4)
  ```
  wget -c https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
  tar -zxf go1.17.2.linux-amd64.tar.gz 
  mv go /usr/local/
  go version
  apt-get install -y tree make nomad=1.1.6 pkg-config lxc-dev gcc
  export GOPATH=/root
  mkdir -p $GOPATH/src/github.com/hashicorp; cd $GOPATH/src/github.com/hashicorp
  git clone https://github.com/hashicorp/nomad-driver-lxc.git
  cd $GOPATH/src/github.com/hashicorp/nomad-driver-lxc
  make build
  ```
- Compile the containerd driver
  ```
  mkdir -p $GOPATH/src/github.com/Roblox
  cd $GOPATH/src/github.com/Roblox
  git clone https://github.com/Roblox/nomad-driver-containerd.git
  cd nomad-driver-containerd
  make build
  ```

- Deploy
  - Create infrastructure
  ```
  terraform init
  terraform apply && source /etc/profile.d/poc.sh
  ```
    - Check that everything is working nice
    ```
    pdsh -g cluster systemctl status consul
    pdsh -g cluster systemctl status nomad
    pdsh -g client consul members
    nomad status
    ```
