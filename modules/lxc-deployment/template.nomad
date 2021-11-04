job "${name}" {
  region = "${region}"
  datacenters = ["${region}"]

  group "${name}" {
    count = 1

    network {
      port "http" {}
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
        template = "/opt/nomad/data/lxc-template.sh"
        template_args = [
          "--shortname=${name}", "--domain=${domain}",
          "--dbhost=${dbhost}", "--dbuser=${dbuser}", "--dbpass=${dbpswd}", "--dbport=${dbport}", "--dbname=${dbname}"
        ]
      }

      resources {
        cpu = 200
        memory = 384
      }
    }
  }
}
