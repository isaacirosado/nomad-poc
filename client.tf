resource "digitalocean_droplet" "client" {
  count = var.clientcount
  image = "ubuntu-20-04-x64"
  name = "client${count.index}"
  tags = ["cluster","client"]
  region = "lon1"
  ssh_keys = [
    32194409 #controller
  ]
  size = "s-2vcpu-4gb"
  droplet_agent = true
}

resource "null_resource" "client-install" {
  count = var.clientcount
  triggers = {
    install = sha1(file("install.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "install.sh"
  }
}

resource "null_resource" "profile-client" {
  count = var.clientcount
  triggers = {
    file = sha1(file("profile-d.sh"))
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
    destination = "/etc/profile.d/poc.sh"
  }
}

#Consul
resource "null_resource" "consul-client" {
  depends_on = [null_resource.client-install]
  count = var.clientcount
  triggers = {
    file = sha1(file("consul-client.hcl"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("consul-client.hcl", {
      dc = digitalocean_droplet.client[count.index].region
      addr = digitalocean_droplet.client[count.index].ipv4_address_private
      token = var.do_token
    })
    destination = "/etc/consul.d/consul.hcl"
  }
}

#Nomad
resource "null_resource" "nomad-client" {
  depends_on = [null_resource.client-install]
  count = var.clientcount
  triggers = {
    file = sha1(file("nomad-client.hcl"))
    plugin = sha1(filebase64("/root/bin/nomad-driver-lxc"))
  }
  provisioner "file" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    content = templatefile("nomad-client.hcl", {
      dc = digitalocean_droplet.client[count.index].region
      addr = digitalocean_droplet.client[count.index].ipv4_address_private
      count = var.clientcount
    })
    destination = "/etc/nomad.d/nomad.hcl"
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

resource "null_resource" "client-services" {
  count = var.clientcount
  triggers = {
    install = sha1(file("enable-services.sh"))
  }
  provisioner "remote-exec" {
    connection {
      host = digitalocean_droplet.client[count.index].ipv4_address
      private_key = file("/root/.ssh/id_rsa")
    }
    script = "enable-services.sh"
  }
}
