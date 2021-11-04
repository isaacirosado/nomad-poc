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
  name = "crd${count.index}"
  region = var.region
  domain = var.domain
}


module "lxc-deployment" {
  depends_on = [null_resource.lxc-image-update]
  count = var.clients
  source = "./modules/lxc-deployment"
  dbcluster = digitalocean_database_cluster.default
  name = "lxc${count.index}"
  region = var.region
  domain = var.domain
}
resource "null_resource" "lxc-iptables-discovery" {
  depends_on = [module.lxc-deployment]
  triggers = {
    files = sha1("./modules/lxc-deployment/iptables.sh")
  }
  provisioner "local-exec" {
    command = "./modules/lxc-deployment/iptables.sh"
  }
}
