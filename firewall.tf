resource "digitalocean_firewall" "default" {
  name = "default"
  droplet_ids = concat(digitalocean_droplet.server.*.id, digitalocean_droplet.client.*.id)
  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_tags = ["controller"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_tags = ["cluster"]
  }
  inbound_rule {
    protocol = "udp"
    port_range = "all"
    source_tags = ["cluster"]
  }
  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol = "udp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
