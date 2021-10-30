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
    target_protocol = "http"
    target_port = 80
#    certificate_name = digitalocean_certificate.cert.name
  }
  healthcheck {
    protocol = "http"
    port = 8080
    path = "/ping"
  }
  droplet_tag = "client"
}
