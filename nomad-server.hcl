enable_syslog = true
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
server {
  enabled = true
  bootstrap_expect = ${count}
}
consul {
  address = "${addr}:8500"
}
