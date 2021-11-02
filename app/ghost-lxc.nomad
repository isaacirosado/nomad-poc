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

      config {
        log_level = "trace"
        verbosity = "verbose"
        template = "/opt/nomad/data/lxc-template"
        template_args = [
          "--port=${httpport}", "--url=http://${name}.${domain}", "--user=node", "--password=blah",
          "--dbhost=${dbhost}", "--dbuser=${dbuser}", "--dbpass=${dbpswd}", "--dbport=${dbport}", "--dbname=${dbname}"
        ]
      }

      resources {
        cpu = 100
        memory = 384
      }
    }
  }
}
