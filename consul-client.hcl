log_level = "DEBUG"
enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
client_addr = "${addr}"
server = false
bind_addr = "${addr}"
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
