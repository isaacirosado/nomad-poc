#resource "digitalocean_certificate" "cert" {
#  name = "rosado-world"
#  type = "lets_encrypt"
#  domains = ["rosado.world"]
#}

resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer"
  region = var.region
#  redirect_http_to_https = true
  forwarding_rule {
    entry_protocol = "http"
    entry_port = 80
#    entry_port = 443
#    entry_protocol = "https"
    target_port = 80
    target_protocol = "http"
#    certificate_name = digitalocean_certificate.cert.name
  }
  healthcheck {
    protocol = "http"
    port = 80
    path = "/ping"
  }
  droplet_tag = "client"
}
