# nomad-poc

## Goal
The goal of this deployment is to have a working PoC infrastructure system to test Nomad/Consul/Traefik/containers deployments:
![Alt text](img/architecture.png?raw=true "Architecture")

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

- Other tools installed locally
  - "pdsh" to run commands in multiple server concurrently
  - "nomad" (as a client to manage deployments), make sure to use the same version as the cluster
  - "dig" for DNS queries
  The deployment will execute "local-prep.sh", that script will install these tools and set up ENV variables

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

- Deploy
  ```
terraform init
  ```
  Create the database and go to the DO dashboard and change the admin user's encryption to "Legacy – MySQL 5.x" (TODO: Upgrade LXC client)
  ```
terraform apply -target="digitalocean_database_cluster.default" --auto-approve
  ```
  Repeat the following command (it is idempotent) as many times as necessary (in case package repos time out or DO's API enforces a rate-limit)
  ```
terraform apply -target="null_resource.local-prep" --auto-approve && ./local-prep.sh && source /etc/profile.d/poc.sh
  ```
  If everything went well, running `nomad status` should succeed and say "No running jobs", now you can finish the rest of the deployment:
  ```
terraform apply --auto-approve
  ```
  Check that everything is working nice using PDSH to run commands in groups/parallel
  ```
pdsh -g cluster systemctl status consul
pdsh -g cluster systemctl status nomad
pdsh -g client consul members
nomad status
  ```
  From day-to-day, destroy the cluster to save some money:
  ```
terraform destroy --auto-approve -target="module.docker-deployment" -target="module.lxc-deployment" && terraform destroy -target="module.cluster-client" -target="module.cluster-server" --auto-approve
  ```
