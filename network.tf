#Need a wildcard cert created in the portal and then import here
resource "digitalocean_certificate" "wildcard" {
  name = "rosado-live-wildcard"
  type = "lets_encrypt"
  domains = [var.domain, "*.${var.domain}"]
  lifecycle {
    prevent_destroy = true
  }
}

#Publicly-available endpoint
resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer"
  region = var.region
  forwarding_rule {
    entry_protocol = "http"
    entry_port = 80
    target_protocol = "http"
    target_port = 80
  }
  forwarding_rule {
    entry_protocol = "https"
    entry_port = 443
    target_protocol = "http"
    target_port = 80
    certificate_name = digitalocean_certificate.wildcard.name
  }
  #There should be one "traefik" instances on each droplet tagges as "client"
  healthcheck {
    protocol = "tcp"
    port = 80
  }
  droplet_tag = "client"
  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_domain" "default" {
  name = var.domain
  lifecycle {
    prevent_destroy = true
  }
}
