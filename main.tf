terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
}

resource "digitalocean_droplet" "test" {
  image = "ubuntu-20-04-x64"
  name = "test"
  region = "lon1"
  ssh_keys = [
    32194238, #james2
    32194228, #james1
    32194225, #matt
    32193692, #isaac's personal
    32194409 #isaac's controller
  ]
  size = "s-1vcpu-1gb"
  droplet_agent = true
  graceful_shutdown = true
}
