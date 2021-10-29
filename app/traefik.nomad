job "traefik" {
  region = "lon1"
  datacenters = ["lon1"]
  type = "system"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
        host_network = "private"
      }
      port "api" {
        static = 8080
        host_network = "private"
      }
    }

    service {
      name = "traefik"
      check {
        name = "alive"
        type = "tcp"
        port = "http"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "traefik" {
      driver = "containerd-driver"
      config {
        image = "traefik:v2.5"
        host_network = true
      }

      resources {
        cpu = 100
        memory = 128
      }
    }
  }
}
