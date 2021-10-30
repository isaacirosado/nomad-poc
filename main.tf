#All the basic stuff to initialize
terraform {
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
