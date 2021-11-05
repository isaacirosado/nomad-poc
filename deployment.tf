#A bit of a "the chicken and the egg" situation
#"local-prep" updates local variables need by the "nomad" provider

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
    domain = var.domain
  })
}

#As an example, deploy an even number of "client" instances with both docker-image and LXC-image
module "containerd-deployment" {
  count = var.clients
  source = "./modules/containerd-deployment"
  dbcluster = digitalocean_database_cluster.default
  name = "ctr${count.index}"
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
resource "null_resource" "lxc-deployment-iptables" {
  depends_on = [module.lxc-deployment]
  triggers = {
    count = var.clients
    script = sha1(file("./modules/lxc-deployment/iptables.sh"))
  }
  provisioner "local-exec" {
    command = "./iptables.sh"
    working_dir = "./modules/lxc-deployment"
  }
}
