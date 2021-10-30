job "demo" {
  region = "lon1"
  datacenters = ["lon1"]

  group "demo" {
    count = 1

    network {
      port "http" {
        to = -1
        host_network = "private"
      }
    }

    service {
      name = "demo"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/demo`)",
      ]
    }

    task "demo" {
      env {
        PORT = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "containerd-driver"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        host_network = true
      }
    }
  }
}
