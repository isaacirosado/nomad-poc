resource "digitalocean_firewall" "default" {
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
    port_range = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
  }
  #My & myself
  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_addresses = ["${var.myip}/32"]
  }
}
