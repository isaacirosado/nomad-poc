resource "null_resource" "enable-services" {
  depends_on = [
    null_resource.consul-server,
    null_resource.consul-client,
    null_resource.nomad-server,
    null_resource.nomad-client
  ]
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
