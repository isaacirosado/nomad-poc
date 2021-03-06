#Setup both Consul and Nomad

module "cluster-server" {
  count = var.servercount
  source = "./modules/cluster-server"
  name = "server${count.index}"
  size = var.servercount
  region = var.region
  do_token = var.do_token
}

module "cluster-client" {
  count = var.size
  depends_on = [module.cluster-server]
  source = "./modules/cluster-client"
  name = "client${count.index}"
  size = var.size
  region = var.region
  do_token = var.do_token
}

resource "null_resource" "expose-dashboards" {
  depends_on = [module.cluster-client]
  triggers = {
    count = var.size
    script = sha1(file("./expose-dashboards.sh"))
  }
  provisioner "local-exec" {
    command = "./expose-dashboards.sh"
  }
}
