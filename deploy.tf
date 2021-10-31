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



resource "digitalocean_database_db" "test" {
 count = var.instancecount
 cluster_id = digitalocean_database_cluster.default.id
 name = "test${count.index}"
}
resource "nomad_job" "test" {
  count = var.instancecount
  depends_on = [nomad_job.traefik]
  jobspec = templatefile("app/ghost-containerd.nomad", {
    name = "test${count.index}"
    region = var.region
    domain = var.domain
    dbhost = digitalocean_database_cluster.default.private_host
    dbport = digitalocean_database_cluster.default.port
    dbuser = digitalocean_database_cluster.default.user
    dbpswd = digitalocean_database_cluster.default.password
    dbname = digitalocean_database_db.test[count.index].name
  })
}
