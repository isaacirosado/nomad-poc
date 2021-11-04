#Create an "internal/trusted" mesh
resource "digitalocean_firewall" "default" {
  name = "default"
  tags = ["cluster"]
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
}
