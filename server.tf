resource "digitalocean_droplet" "server" {
  count = var.servercount
  image = "ubuntu-20-04-x64"
  name = "server${count.index}"
  tags = ["cluster","server"]
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
  #graceful_shutdown = true
}

resource "null_resource" "server-common" {
  count = var.servercount
  triggers = {
    common = sha1(file("common.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "common.sh"
  }
}
resource "null_resource" "config-server-common" {
  depends_on = [null_resource.server-common]
  count = var.servercount
  triggers = {
    common = sha1(file("common.sh"))
    file = sha1(file("nomad.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("nomad.hcl", {
      dc = digitalocean_droplet.server[count.index].region
      addr = digitalocean_droplet.server[count.index].ipv4_address_private
    })
    destination = "/etc/nomad.d/nomad.hcl"
  }
}
resource "null_resource" "config-server" {
  depends_on = [null_resource.config-server-common]
  count = var.servercount
  triggers = {
    file = sha1(file("server.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("server.hcl", {
      count = var.servercount,
      servers = jsonencode(digitalocean_droplet.server.*.ipv4_address_private)
    })
    destination = "/etc/nomad.d/server.hcl"
  }
}

resource "null_resource" "server-enable-service" {
  depends_on = [null_resource.config-server]
  count = var.servercount
  triggers = {
    common = sha1(file("service.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.server[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "service.sh"
  }
}
