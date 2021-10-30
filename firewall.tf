#Completely over-the-top way to get my IP
resource "null_resource" "myip" {
  triggers  =  {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    command = "lsof -nP  | grep -ie ':22->.*established' | sed -e 's|.*>||g' -e 's|:.*$||g' > ${path.module}/myip.txt"
  }
}
data "local_file" "myip" {
  depends_on = [null_resource.myip]
  filename = "${path.module}/myip.txt"
}

resource "digitalocean_firewall" "default" {
  depends_on = [null_resource.myip]
  name = "default"
  droplet_ids = concat(digitalocean_droplet.server.*.id, digitalocean_droplet.client.*.id)
  #Internal mesh
  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_tags = ["controller","cluster"]
  }
  inbound_rule {
    protocol = "udp"
    port_range = "all"
    source_tags = ["controller","cluster"]
  }
  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol = "udp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  #External traffic (applies to all droplets, but the balancer ONLY knows about the client droplets)
  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
  }
  #My & myself
  dynamic "inbound_rule" {
    for_each = toset(compact(split("\n", data.local_file.myip.content)))
    content {
      protocol = "tcp"
      port_range = "all"
      source_addresses = ["${inbound_rule.value}/32"]
    }
  }
}
