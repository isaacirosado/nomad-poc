#Create an "internal/trusted" mesh
resource "digitalocean_firewall" "internal" {
  name = "internal"
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
}
#External traffic
resource "digitalocean_firewall" "external" {
  name = "external"
  tags = ["client"]
  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "8080"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
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
}
#Admin controller
resource "digitalocean_firewall" "controller" {
  name = "controller"
  tags = ["controller"]
  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0"]
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
}
