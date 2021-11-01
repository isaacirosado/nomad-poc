resource "null_resource" "deploy-prep" {
  depends_on = [null_resource.client-services, null_resource.server-services]
  triggers = {
    script = sha1(file("deploy-prep.sh"))
    lxc = sha1(file("app/lxc-template"))
  }
  provisioner "local-exec" {
    command = "bash deploy-prep.sh"
  }
}

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
 count = var.instancecount*2
 cluster_id = digitalocean_database_cluster.default.id
 name = "test${count.index}"
}
#Containerd deployment
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
#LXC deployment
resource "random_integer" "staticport" {
  count = var.instancecount
  min = 17000
  max = 19999
  keepers = {
    script = sha1(file("deploy-prep.sh"))
    lxc = sha1(file("app/lxc-template"))
  }
}
resource "nomad_job" "lxc" {
  depends_on = [nomad_job.traefik, null_resource.deploy-prep]
  count = 1
  #count = var.instancecount
  jobspec = templatefile("app/ghost-lxc.nomad", {
    name = "test${count.index + var.instancecount}"
    httpport = random_integer.staticport[count.index].result
    region = var.region
    domain = var.domain
    dbhost = digitalocean_database_cluster.default.private_host
    dbport = digitalocean_database_cluster.default.port
    dbuser = digitalocean_database_cluster.default.user
    dbpswd = digitalocean_database_cluster.default.password
    dbname = digitalocean_database_db.test[count.index].name
  })
  purge_on_destroy = true
}
