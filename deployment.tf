resource "null_resource" "local-prep" {
  depends_on = [module.cluster-client]
  triggers = {
    script = sha1(file("local-prep.sh"))
  }
  provisioner "local-exec" {
    command = "./local-prep.sh"
  }
}

provider "nomad" {
  region = var.region
}

resource "nomad_job" "traefik" {
  depends_on = [null_resource.local-prep]
  jobspec = templatefile("traefik.nomad", {
    region = var.region
  })
}

module "containerd-deployment" {
  count = var.clients
  source = "./modules/containerd-deployment"
  dbcluster = digitalocean_database_cluster.default
  name = "test${count.index}"
  region = var.region
  domain = var.domain
}


resource "random_integer" "port" {
  count = var.clients
  min = 17000
  max = 19999
}
module "lxc-deployment" {
  depends_on = [null_resource.lxc-image-update]
  count = var.clients
  source = "./modules/lxc-deployment"
  dbcluster = digitalocean_database_cluster.default
  name = "test${count.index + var.clients}"
  region = var.region
  domain = var.domain
  port = random_integer.port[count.index].result
}
