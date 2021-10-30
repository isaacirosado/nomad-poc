job "test" {
  region = "lon1"
  datacenters = ["lon1"]

  group "test" {
    count = 1

    network {
      port "http" {
	static = 2368
        host_network = "private"
      }
    }

    service {
      name = "test"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.test.rule=Host(`test.rosado.live`)"
      ]
    }

    task "test" {
      driver = "containerd-driver"
      #env {
      #  url = "https://test.rosado.live"
      #}

      config {
        image = "ghost:4.20"
        host_network = true
      }
    }
  }
}
