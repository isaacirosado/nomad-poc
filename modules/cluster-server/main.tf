terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
variable "name" {}
variable "region" {}
variable "size" {}
variable "do_token" {}

resource "digitalocean_droplet" "main" {
  image = "ubuntu-20-04-x64"
  name = var.name
  tags = ["cluster","server"]
  region = var.region
  ssh_keys = [
    32194409 #controller
  ]
  size = "s-2vcpu-4gb"
  droplet_agent = true
}
output "internaladdr" {
  value = digitalocean_droplet.main.ipv4_address_private
}

resource "null_resource" "main-install" {
  triggers = {
    install = sha1(file("${path.module}/install.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "${path.module}/install.sh"
  }
}

resource "null_resource" "profiled" {
  depends_on = [null_resource.main-install]
  triggers = {
    file = sha1(file("${path.module}/profile-d.sh"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("${path.module}/profile-d.sh", {
      addr = digitalocean_droplet.main.ipv4_address_private
      dc = digitalocean_droplet.main.region
    })
    destination = "/etc/profile.d/poc.sh"
  }
}

resource "null_resource" "consul-main" {
  depends_on = [null_resource.profiled]
  triggers = {
    file = sha1(file("${path.module}/consul.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("${path.module}/consul.hcl", {
      dc = digitalocean_droplet.main.region
      token = var.do_token
      size = var.size
    })
    destination = "/etc/consul.d/consul.hcl"
  }
}

resource "null_resource" "nomad-main" {
  depends_on = [null_resource.profiled]
  triggers = {
    file = sha1(file("${path.module}/nomad.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("${path.module}/nomad.hcl", {
      dc = digitalocean_droplet.main.region
      addr = digitalocean_droplet.main.ipv4_address_private
      size = var.size
    })
    destination = "/etc/nomad.d/nomad.hcl"
  }
}

resource "null_resource" "services" {
  depends_on = [null_resource.nomad-main]
  triggers = {
    install = sha1(file("${path.module}/enable-services.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "${path.module}/enable-services.sh"
  }
}
