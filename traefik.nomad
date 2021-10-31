job "traefik" {
  region = "${region}"
  datacenters = ["${region}"]
  type = "system"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }
      port "api" {
        static = 8080
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
          "--entryPoints.web.address=$${NOMAD_HOST_ADDR_http}", "--entryPoints.traefik.address=$${NOMAD_ADDR_api}",
          "--api.insecure=true", "--api.dashboard=true", "--ping=true",
          "--providers.consul.endpoints=127.0.0.1:8500",
          "--providers.consulcatalog.endpoint.scheme=http", "--providers.consulcatalog.exposedByDefault=false"
        ]
      }

      resources {
        cpu = 100
        memory = 128
      }
    }
  }
}
