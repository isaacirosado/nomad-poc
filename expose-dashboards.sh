#!/bin/bash
# Example of manual service registrations to Consul with proper tagging so the load-balancer will pick them up
set -xe
set -o errexit
set -o nounset
set -o pipefail

consul services register -port=4646 -name=nomad-dashboard -tag="traefik.enable=true" -tag='traefik.http.routers.nomad-dashboard.rule=Host(`nomad.rosado.live`)' -tag="traefik.http.routers.nomad-dashboard.middlewares=auth" -tag='traefik.http.middlewares.auth.basicauth.users=ghost:$apr1$x7.AV8Ov$sUu7JOkV9yoKIXkI3biBq.'

consul services register -port=8500 -name=consul-dashboard -tag="traefik.enable=true" -tag='traefik.http.routers.consul-dashboard.rule=Host(`consul.rosado.live`)' -tag="traefik.http.routers.consul-dashboard.middlewares=auth" -tag='traefik.http.middlewares.auth.basicauth.users=ghost:$apr1$x7.AV8Ov$sUu7JOkV9yoKIXkI3biBq.'
