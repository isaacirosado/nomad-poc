log_level = "DEBUG"
enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
client_addr = "${addr}"
server = true
bind_addr = "${addr}"
bootstrap_expect = ${count}
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
