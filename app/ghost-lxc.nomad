job "${name}" {
  region = "${region}"
  datacenters = ["${region}"]

  group "${name}" {
    count = 1

    network {
      port "http" {
        static = ${httpport}
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
      driver = "lxc"
      #env {
      #  database___client = "mysql"
      #  database___connection__host = "${dbhost}"
      #  database___connection__port = "${dbport}"
      #  database___connection__user = "${dbuser}"
      #  database___connection__password = "${dbpswd}"
      #  database___connection__database = "${dbname}"
      #}

      config {
        log_level = "trace"
        verbosity = "verbose"
        template = "/opt/nomad/data/lxc-template"
        template_args = ["-F", "--port=${httpport}", "--url=http://${name}.${domain}", "--user=node", "--password=blah"]
      }

      resources {
        cpu = 100
        memory = 384
      }
    }
  }
}
