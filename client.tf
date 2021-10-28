resource "digitalocean_droplet" "client" {
  count = var.clientcount
  image = "ubuntu-20-04-x64"
  name = "client${count.index}"
  tags = ["cluster","client"]
  region = "lon1"
  ssh_keys = [
    32194238, #james2
    32194228, #james1
    32194225, #matt
    32193692, #isaac's personal
    32194409 #isaac's controller
  ]
  size = "s-2vcpu-4gb"
  droplet_agent = true
  #graceful_shutdown = true
}

resource "null_resource" "client-common" {
  count = var.clientcount
  triggers = {
    common = sha1(file("common.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "common.sh"
  }
}
resource "null_resource" "config-client" {
  depends_on = [null_resource.client-common]
  count = var.clientcount
  triggers = {
    file = sha1(file("client.hcl"))
    file2 = sha1(file("profile-d.sh"))
    file3 = sha1(filebase64("/root/bin/nomad-driver-lxc"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("client.hcl", {
      count = var.clientcount
      servers = jsonencode(digitalocean_droplet.server.*.ipv4_address_private)
      dc = digitalocean_droplet.client[count.index].region
      addr = digitalocean_droplet.client[count.index].ipv4_address_private
    })
    destination = "/etc/nomad.d/nomad.hcl"
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("profile-d.sh", {
      addr = digitalocean_droplet.client[count.index].ipv4_address_private
      dc = digitalocean_droplet.client[count.index].region
    })
    destination = "/etc/profile.d/nomad.sh"
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    source = "/root/bin/nomad-driver-lxc"
    destination = "/opt/nomad/plugins/nomad-driver-lxc"
  }
}

resource "null_resource" "client-enable-service" {
  depends_on = [null_resource.config-client]
  count = var.clientcount
  triggers = {
    common = sha1(file("service.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "service.sh"
  }
}
