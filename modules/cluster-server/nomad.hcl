enable_syslog = true
log_level = "warn"
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
server {
  enabled = true
  bootstrap_expect = ${size}
}
consul {
  address = "${addr}:8500"
}
