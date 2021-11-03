enable_syslog = true
datacenter = "${dc}"
data_dir = "/opt/consul"
server = true
bind_addr = "{{ GetInterfaceIP \"eth1\" }}"
client_addr = "{{ GetInterfaceIP \"eth1\" }}"
bootstrap_expect = ${size}
retry_join = ["provider=digitalocean region=${dc} tag_name=server api_token=${token}"]
