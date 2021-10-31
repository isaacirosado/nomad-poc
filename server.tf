resource "digitalocean_droplet" "server" {
  count = var.servercount
  image = "ubuntu-20-04-x64"
  name = "server${count.index}"
  tags = ["cluster","server"]
  region = var.region
  ssh_keys = [
    32194409 #controller
  ]
  size = "s-2vcpu-2gb"
  droplet_agent = true
}

resource "null_resource" "server-install" {
  count = var.servercount
  triggers = {
    id = digitalocean_droplet.server[count.index].id
    install = sha1(file("install.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "install.sh"
  }
}

resource "null_resource" "profile-server" {
  count = var.servercount
  triggers = {
    id = digitalocean_droplet.server[count.index].id
    file = sha1(file("profile-d.sh"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("profile-d.sh", {
      addr = digitalocean_droplet.server[count.index].ipv4_address_private
      dc = var.region
    })
    destination = "/etc/profile.d/poc.sh"
  }
}

#Consul
resource "null_resource" "consul-server" {
  depends_on = [null_resource.server-install]
  count = var.servercount
  triggers = {
    id = digitalocean_droplet.server[count.index].id
    file = sha1(file("consul-server.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("consul-server.hcl", {
      dc = var.region
      addr = digitalocean_droplet.server[count.index].ipv4_address_private
      count = var.servercount
      token = var.do_token
    })
    destination = "/etc/consul.d/consul.hcl"
  }
}

#Nomad
resource "null_resource" "nomad-server" {
  depends_on = [null_resource.server-install]
  count = var.servercount
  triggers = {
    id = digitalocean_droplet.server[count.index].id
    file = sha1(file("nomad-server.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("nomad-server.hcl", {
      dc = digitalocean_droplet.server[count.index].region
      addr = digitalocean_droplet.server[count.index].ipv4_address_private
      count = var.servercount
    })
    destination = "/etc/nomad.d/nomad.hcl"
  }
}

resource "null_resource" "server-services" {
  depends_on = [null_resource.consul-server,null_resource.nomad-server]
  count = var.servercount
  triggers = {
    id = digitalocean_droplet.server[count.index].id
    install = sha1(file("enable-services.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "enable-services.sh"
  }
}
