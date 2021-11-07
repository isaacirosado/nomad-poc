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
  tags = ["cluster","client"]
  region = var.region
  ssh_keys = [
    32194409 #controller
  ]
  size = "s-4vcpu-8gb"
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
      count = var.size
    })
    destination = "/etc/nomad.d/nomad.hcl"
  }
}
resource "null_resource" "nomad-plugins" {
  depends_on = [null_resource.nomad-main]
  triggers = {
    lxc = sha1(filebase64("/root/bin/nomad-driver-lxc"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    source = "/root/bin/nomad-driver-lxc"
    destination = "/opt/nomad/plugins/nomad-driver-lxc"
  }
}
resource "null_resource" "nomad-cni" {
  depends_on = [null_resource.nomad-plugins]
  triggers = {
    cni = sha1(file("${path.module}/cni.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.main.ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "${path.module}/cni.sh"
  }
}

resource "null_resource" "services" {
  depends_on = [null_resource.nomad-cni]
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

resource "null_resource" "lxc-image-update" {
  depends_on = [null_resource.services]
  provisioner "local-exec" {
    command = "./sync.sh ${digitalocean_droplet.main.ipv4_address_private}"
    working_dir = "lxc-image"
  }
}

