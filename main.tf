#All the basic stuff to initialize
terraform {
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

#DO!
variable "do_token" {}
variable "region" {
  default = "lon1"
}
provider "digitalocean" {
  token = var.do_token
}

variable "servercount" {
  default = 3
}

variable "clientcount" {
  default = 4
}

variable "myip" {
  default = "120.147.138.51"
}

variable "domain" {
  default = "rosado.live"
}

variable "vpcid" {
  default = "112b5b44-783b-4a7d-ad6e-fb5d86ada5d0"
}

variable "instancecount" {
  default = 9
}
