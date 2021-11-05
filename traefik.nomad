job "traefik" {
  region = "${region}"
  datacenters = ["${region}"]
  type = "system" #guarantee an even count on each droplet

  group "traefik" {
    count = 1
    network {
      port "dashboard" {
        static = 8080
      }
    }

    service {
      name = "traefik"
      check {
        name = "ping"
        port = "dashboard"
        type = "http"
        path = "/ping"
        interval = "10s"
        timeout  = "2s"
        check_restart {
          limit = 2
          grace = "10s"
          ignore_warnings = false
        }
      }
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik-dashboard.rule=Host(`traefik.${domain}`)",
        "traefik.http.routers.traefik-dashboard.service=api@internal",
        "traefik.http.routers.traefik-dashboard.middlewares=auth",
        "traefik.http.middlewares.auth.basicauth.users=ghost:$apr1$x7.AV8Ov$sUu7JOkV9yoKIXkI3biBq."
      ]
    }

    task "traefik" {
      driver = "containerd-driver"
      config {
        image = "traefik:v2.5"
        host_network = true
        args = [
          "--entryPoints.web.address=:80",
          "--api=true", "--api.dashboard=true", "--ping=true",
          "--providers.consul.endpoints=127.0.0.1:8500",
          "--providers.consulcatalog.endpoint.scheme=http", "--providers.consulcatalog.exposedByDefault=false"
        ]
        #sysctl = {
        #  "fs.file-max" = "16384"
        #}
      }

      resources {
        cpu = 600
        memory = 512
      }
    }
  }
}
