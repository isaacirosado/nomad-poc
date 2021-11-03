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
    }

    task "${name}" {
      driver = "lxc"

      config {
        log_level = "trace"
        verbosity = "verbose"
        template = "/opt/nomad/data/lxc-template-cp"
        template_args = [
          "--version=${version}",
          "--port=${httpport}", "--shortname=${name}", "--domain=${domain}",
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
