enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
server = true
bind_addr = "${addr}"
client_addr = "127.0.0.1"
bootstrap_expect = ${count}
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
