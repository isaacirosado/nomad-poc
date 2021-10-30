log_level = "DEBUG"
enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
server = false
bind_addr = "${addr}"
client_addr = "127.0.0.1"
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
limits {
  http_max_conns_per_client = 400
}
