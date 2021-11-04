enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
server = false
bind_addr = "{{ GetInterfaceIP \"eth1\" }}"
client_addr = "127.0.0.1 {{ GetInterfaceIP \"eth1\" }} {{ GetInterfaceIP \"lxcbr0\" }}"
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
limits {
  http_max_conns_per_client = 1200
}
ui_config {
  enabled = true
}
