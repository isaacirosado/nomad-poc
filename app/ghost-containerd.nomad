job "${name}" {
  region = "${region}"
  datacenters = ["${region}"]

  group "${name}" {
    count = 1

    network {
      port "http" {
        to = 2368
      }
      mode = "bridge"
      dns {
        servers = ["8.8.8.8"]
      }
    }

    service {
      name = "${name}"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${name}.rule=Host(`${name}.${domain}`)"
      ]
    }

    task "${name}" {
      driver = "containerd-driver"
      env {
        url = "http://${name}.${domain}"
        database___client = "mysql"
        database___connection__host = "${dbhost}"
        database___connection__port = "${dbport}"
        database___connection__user = "${dbuser}"
        database___connection__password = "${dbpswd}"
        database___connection__database = "${dbname}"
      }

      config {
        image = "ghost:${version}"
      }
      resources {
        cpu = 200
        memory = 384
      }
    }
  }
}
