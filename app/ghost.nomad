job "test1" {
  region = "lon1"
  datacenters = ["lon1"]

  group "test1" {
    count = 1

    network {
      port "http" {
        to = 2368
      }
      mode = "bridge"
    }

    service {
      name = "test1"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.test1.rule=Host(`test1.rosado.live`)"
      ]
    }

    task "test1" {
      driver = "containerd-driver"
      env {
        url = "http://test1.rosado.live"
      }


      config {
        image = "ghost:4.20"
      }
    }
  }
}
