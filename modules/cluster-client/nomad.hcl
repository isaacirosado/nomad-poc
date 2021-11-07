enable_syslog = true
log_level = "warn"
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
client {
  enabled = true
  network_interface = "eth1"
}
consul {
  address = "${addr}:8500"
}
