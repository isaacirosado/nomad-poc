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
  address = "127.0.0.1:8500"
}
