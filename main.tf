#Using Terraform is pretty cool
terraform {
  backend "local" {
    path = "/root/terraform.tfstate"
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

#Digital Ocean's token and cloud settings
variable "do_token" {}
variable "region" {
  default = "lon1"
}
provider "digitalocean" {
  token = var.do_token
}
variable "domain" {
  default = "rosado.live"
}
variable "vpcid" {
  default = "112b5b44-783b-4a7d-ad6e-fb5d86ada5d0"
}

#Number of servers in the cluster (3 or 5 works best)
variable "servercount" {
  default = 3
}

#Number of clients in the cluster (needs to be able to fit deployments)
variable "size" {
  default = 4
}

#Baseline of client deployment/instances (x2 since we'll have one of each image type)
variable "clients" {
  default = 12
}
