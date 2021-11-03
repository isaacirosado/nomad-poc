log_level = "DEBUG"
enable_syslog = true
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
plugin "containerd-driver" {
  config {
    enabled = true
    containerd_runtime = "io.containerd.runc.v2"
    stats_interval = "5s"
  }
}
