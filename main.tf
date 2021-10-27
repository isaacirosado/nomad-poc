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
provider "digitalocean" {}

variable "nodecount" {
  default = 5
}

#Create nodes with our default SSH keys
resource "digitalocean_droplet" "cluster" {
  count = var.nodecount
  image = "ubuntu-20-04-x64"
  name = "node${count.index}"
  tags = ["cluster"]
  region = "lon1"
  ssh_keys = [
    32194238, #james2
    32194228, #james1
    32194225, #matt
    32193692, #isaac's personal
    32194409 #isaac's controller
  ]
  size = "s-1vcpu-1gb"
  droplet_agent = true
  graceful_shutdown = true
}

#Bootstrap the node (TODO: Convert to a base image to speed up installations and enable authoritative testing)
resource "null_resource" "node-setup" {
  count = var.nodecount
  triggers = {
    checksum = sha1(file("node-setup.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.cluster[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "node-setup.sh"
  }
}
