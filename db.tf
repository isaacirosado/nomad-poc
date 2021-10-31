resource "digitalocean_database_cluster" "default" {
  name = "isaaclivedb"
  engine = "mysql"
  version = "8"
  size = "db-s-2vcpu-4gb"
  region = var.region
  private_network_uuid = var.vpcid
  node_count = 3
}

resource "digitalocean_database_firewall" "default" {
  cluster_id = digitalocean_database_cluster.default.id
  rule {
    type = "tag"
    value = "cluster"
  }
}
