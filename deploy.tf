provider "nomad" {
  address = "http://${digitalocean_droplet.client[0].ipv4_address_private}:4646"
  region = var.region
}

resource "nomad_job" "traefik" {
  depends_on = [null_resource.client-services]
  jobspec = templatefile("traefik.nomad", {
    region = var.region
  })
}



resource "digitalocean_database_db" "test1" {
 cluster_id = digitalocean_database_cluster.default.id
 name = "test1"
}
resource "nomad_job" "test1" {
  depends_on = [nomad_job.traefik]
  jobspec = templatefile("app/ghost-containerd.nomad", {
    name = "test1"
    region = var.region
    domain = var.domain
    dbhost = digitalocean_database_cluster.default.private_host
    dbport = digitalocean_database_cluster.default.port
    dbuser = digitalocean_database_cluster.default.user
    dbpswd = digitalocean_database_cluster.default.password
    dbname = digitalocean_database_db.test1.name
  })
}
