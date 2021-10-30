job "traefik" {
  region = "lon1"
  datacenters = ["lon1"]
  type = "system"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
        host_network = "public"
      }
      port "api" {
        static = 8080
        host_network = "private"
      }
    }

    service {
      name = "traefik"
    }

    task "traefik" {
      driver = "containerd-driver"
      config {
        image = "traefik:v2.5"
        host_network = true
        args = [
          "--api.insecure=true", "--api.dashboard=true",
          "--providers.consul.endpoints=127.0.0.1:8500", "--providers.consulcatalog.endpoint.scheme=http"
        ]
      }

      resources {
        cpu = 100
        memory = 128
      }
    }
  }
}
