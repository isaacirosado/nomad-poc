log_level = "DEBUG"
enable_syslog = true
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
server {
  enabled = true
  bootstrap_expect = ${count}
  server_join {
    retry_join = ${servers}
  }
}
