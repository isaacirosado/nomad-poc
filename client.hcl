log_level = "DEBUG"
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
client {
  enabled = true
  server_join {
    retry_join = ${servers}
  }
}
