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
