terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
variable "name" {}
variable "region" {}
variable "domain" {}
variable "dbcluster" {
  type = object({
    id = string
    private_host = string
    port = number
    user = string
    password = string
  })
}

resource "digitalocean_database_db" "main" {
 cluster_id = var.dbcluster.id
 name = var.name
}
resource "nomad_job" "main" {
  jobspec = templatefile("${path.module}/template.nomad", {
    name = var.name
    region = var.region
    domain = var.domain
    dbhost = var.dbcluster.private_host
    dbport = var.dbcluster.port
    dbuser = var.dbcluster.user
    dbpswd = var.dbcluster.password
    dbname = digitalocean_database_db.main.name
  })
  detach = false
}
