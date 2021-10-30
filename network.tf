resource "digitalocean_certificate" "cert" {
  name = var.domain
  type = "lets_encrypt"
  domains = [var.domain]
  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer"
  region = var.region
  redirect_http_to_https = true
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
    certificate_name = digitalocean_certificate.cert.name
  }
  healthcheck {
    protocol = "http"
    port = 8080
    path = "/ping"
  }
  droplet_tag = "client"
  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_domain" "default" {
  name = var.domain
  ip_address = digitalocean_loadbalancer.public.ip
  lifecycle {
    prevent_destroy = true
  }
}
